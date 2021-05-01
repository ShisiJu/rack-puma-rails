# rack puma rails

## 背景

## 说明

- rack
- puma
- rails 6.1

## 简述

## rack

```rb

```

## puma

puma-master\lib\puma\rack_default.rb

```rb
require 'rack/handler/puma'

module Rack::Handler
  def self.default(options = {})
    Rack::Handler::Puma
  end
end
```

puma-master\lib\rack\handler\puma.rb

```rb


```

```
bundle exec puma
```

常见的 rack 服务器

- puma (rails 默认的 web server)
- unicorn
- webrick (rack 自带的)

https://en.wikipedia.org/wiki/Mastodon_(software)

[puma](https://puma.io/)

Puma was born from [Mongrel](<https://en.wikipedia.org/wiki/Mongrel_(web_server)>) and began moving forward.

Unlike other Ruby Webservers, Puma was built for speed and parallelism. Puma is a small library that provides a very fast and concurrent HTTP 1.1 server for Ruby web applications. It is designed for running Rack apps only.

What makes Puma so fast is the careful use of a [Ragel](https://en.wikipedia.org/wiki/Ragel) extension to provide fast, accurate HTTP 1.1 protocol parsing. This makes the server scream without too many portability issues.

## rails

rails-6-1-stable\railties\lib\rails\cli.rb

rails-6-1-stable\railties\lib\rails\commands\server\server_command.rb

```rb
def use_puma?
  server.to_s == "Rack::Handler::Puma"
end
```

```sh
rails server
```

## 总结

## 参考文档

- [a-simple-intro-to-writing-a-lexer-with-ragel](http://thingsaaronmade.com/blog/a-simple-intro-to-writing-a-lexer-with-ragel.html)
-
