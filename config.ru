require 'async/redis'

if ENV.key?("REDIS_URL")
  endpoint = Async::Redis::Endpoint.parse(ENV["REDIS_URL"])
  client = Async::Redis::Client.new(endpoint)
else
  client = Async::Redis::Client.new
end

def streaming_body(client)
  proc do |stream|
    subscription_task = Async do
      # Subscribe to the redis channel and forward messages to the client:
      client.subscribe("chat") do |context|
        context.each do |type, name, message|
          stream.write(message)
        end
      end
    end

    stream.each do |message|
      # Read messages from the client and publish them to the redis channel:
      puts "got message #{message}"

      client.publish("chat", message.upcase)
    end
  rescue => error
  ensure
    subscription_task&.stop
    stream.close(error)
  end
end

def error_body(status)
  proc do |stream|
    writer = Async do
      stream.write("Returning HTTP status #{status}")
    end
  rescue => error
  ensure
    writer&.stop
    stream.close(error)
  end
end

run do |env|
  puts "got PATH_INFO #{env["PATH_INFO"]}"
  case env["PATH_INFO"]
  when /\d\d\d/
    status = env["PATH_INFO"][1..-1].to_i
    puts "returning status #{status}"
    [status.to_i, {
      "Content-Type" => "message/ohttp-chunked-res",
      "Incremental" => "?1"
    }, error_body(status)]
  else
    [200, {
      "Content-Type" => "message/ohttp-chunked-res",
      "Incremental" => "?1"
    }, streaming_body(client)]
  end
end
