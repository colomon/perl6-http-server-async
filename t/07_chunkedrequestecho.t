#!/usr/bin/env perl6-j

use HTTP::Server::Async;
use Test;

plan 1;

my $s = HTTP::Server::Async.new;
$s.register(sub ($request, $response, $n) {
  await $request.promise;
  $response.headers<Content-Type> = 'text/plain';
  $response.status = 200;
  $response.close($request.data);
});
$s.listen;

my $host = '127.0.0.1';
my $port = 8080;
 
my $client = IO::Socket::INET.new(:$host, :$port);
$client.send("GET / HTTP/1.0\r\nTransfer-Encoding: chunked\r\n\r\n");
my @chunks = "4\r\n", "Wiki\r\n", "5\r\n", "pedia\r\n", "e\r\n", " in\r\n\r\nchunks.\r\n", "0\r\n", "\r\n";
for @chunks -> $chunk {
  $client.send($chunk);
  sleep 1;
}

my $data;
while (my $str = $client.recv) {
  $data ~= $str;
}
$client.close;
ok $data ~~ / "\r\n\r\nWikipedia in\r\n\r\nchunks" /, 'Test for chunked data echo';
# vi:syntax=perl6
