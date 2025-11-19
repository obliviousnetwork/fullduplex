# fullduplex

This repo includes an example server and client able to simultaneously stream both request and response bodies over HTTP.

## Setup

1. Install Ruby.
2. Run `bin/setup` to install required gems.

## Usage

To test bidirectional streaming against an Oblivious Network relay, run `bin/client`.

Enter any text, and after pushing return in the client, that line will be streamed to the server. The server will reply with the same line in uppercase text, and keep the connection open. To close the connection, push `Ctrl-D`.

## Local Development

Run `bin/server` to start the server. Then, run `bin/client http://localhost:4444`.
