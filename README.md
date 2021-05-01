# rack puma rails

## 背景

2021 年 五一, 突然对 web server 产生了兴趣,
好奇我们的程序是如何接收到请求, 找到我们的程序代码,并返回对应的结果的;

于是, 便写下这篇文章;

## 说明

文章所涉及到的代码已上传 [GitHub rack-puma-rails](https://github.com/ShisiJu/rack-puma-rails)

文章涉及到的程序版本

- [rack 2.2](https://github.com/rack/rack)
- [puma 5.1](https://github.com/puma/puma)
- [rails 6.1](http://rubyonrails.org/)

文中提到的 web server 是指的服务器软件, 而非计算机.

## 简述

rack 是一个 ruby web server(例如: puma, unicorn) 和 应用程序(例如: rails)之间的桥梁;

## rack

![rack-logo](./photos/rack-logo.png)

### Rack 是什么

Rack 提供了一个最小化的, 模块化, 可适配化的接口给 Ruby 的 web 应用;

通过简单的方式封装 HTTP 请求和响应, Rack 统一并提取了 API 给 web server,
web 框架以及在两者之间的中间件(middleware).

### 为什么要使用 Rack

在没有 Rack 之前, web server 的实现各有千秋, web 应用对接不同的 web server,
需要一个 server 对应一套逻辑; 缺乏统一的标准;

![before-rack](./photos/before-rack.png)

这些适配不同 server 的工作, 没有太大意义, 人们期望有一个统一的规范, 能够让 web server 和
web 应用可以随意组合, 且只需要简单的配置.

Rack 的出现解决了 web server 和 web 应用之间配置的问题;

> 复杂的程序需要分层

通过 Rack, 不同的 web server 和 不同的应用框架可以非常简单地集成;

![rack-model](./photos/rack-model.png)

接下来, 我们就来详细看一下 Rack 的协议和中间件.

### Rack 协议与中间件

Rack 作为 web server 与应用框架之间的桥梁.
最为重要的就是定义一套清晰的`协议(protocol)`.

#### Rack 协议

我们也可以使用 Rack 的中间件

我们先来看一下[rack 协议](https://github.com/rack/rack/blob/master/SPEC.rdoc)

所有的 webserver 只需要在 Rack::Handler 的模块中创建一个实现了 .run 方法的类就可以了：

一个 Rack 应用是一个 Ruby 的对象(object), 而不是一个类(class).
这个对象需要实现`call`方法;

call 方法`只有一个`参数 `env` 环境, 并且要返回一个数组, 数组必须返回是三个值.
HTTP 的 status , headers, 和 body;

> Rack 的协议脱胎于 python 的[pep-0333 Python Web Server Gateway Interface](https://www.python.org/dev/peps/pep-0333/)

我们可以看一个小案例, 要确保已安装了 `rack` 和 `puma`

我们在 `config.ru` 简单写一个处理请求的 rack 对象

```rb
# config.ru rack的默认配置文件
# rack对象, 接收一个env参数, 且要返回一个数组
APP = ->(env) { [200, {}, [env.inspect]] }
run ->(env) { APP.call(env) }
```

执行`rackup`

```sh
rackup
```

![rackup](./photos/rackup.png)

我们可以看到 `rackup`执行之后, `puma` 也随之启动了!

我们可以在浏览器中看一下效果 [http://localhost:9292/hello_world](http://localhost:9292/hello_world)

在浏览器中可以看到打印的`env`对象

接下来, 我们看看`rackup`到底做了什么, 能够让 puma 运行起来;

```sh
$ which rackup
/d/env/ruby/Ruby26-x64/bin/rackup
```

我们来看一下对应的代码

```rb
# gem自动生成的文件, 方便使用, 省去了一些代码
version = ">= 0.a"
load Gem.activate_bin_path('rack', 'rackup', version)
```

我们在`pry`执行一下看看

```sh
[1] pry(main)> require 'rubygems'
=> false
[2] pry(main)> version = ">= 0.a"
=> ">= 0.a"
[3] pry(main)> Gem.activate_bin_path('rack', 'rackup', version)
=> "D:/env/ruby/Ruby26-x64/lib/ruby/gems/2.6.0/gems/rack-2.2.3/bin/rackup"
```

```rb
def self.new_from_string(builder_script, file = "(rackup)")
      # We want to build a variant of TOPLEVEL_BINDING with self as a Rack::Builder instance.
      # We cannot use instance_eval(String) as that would resolve constants differently.
      binding, builder = TOPLEVEL_BINDING.eval('Rack::Builder.new.instance_eval { [binding, self] }')
      eval builder_script, binding, file

      return builder.to_app
end
```

- rack 中间件

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
所有遵循 Rack 协议的 webserver 都会实现上述 .run 方法接受 app、options 和一个 block 作为参数运行一个进程来处理所有的来自用户的 HTTP 请求，在这里就是每个 webserver 自己需要解决的了

```rb
require 'rack/handler'

# 省略了很多配置的代码
module Rack
  module Handler
    module Puma
      DEFAULT_OPTIONS = {
        :Verbose => false,
        :Silent  => false
      }

      # 注册rack服务器名称
      register :puma, Puma
      def self.run(app, **options)
        conf   = self.config(app, options)
        events = options.delete(:Silent) ? ::Puma::Events.strings : ::Puma::Events.stdio
        launcher = ::Puma::Launcher.new(conf, :events => events)

        yield launcher if block_given?
        begin
          launcher.run
        rescue Interrupt
          puts "* Gracefully stopping, waiting for requests to finish"
          launcher.stop
          puts "* Goodbye!"
        end
      end
    end
  end
end
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

rails 是基于 rack 的

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
- [rubyguides rack-middleware](https://www.rubyguides.com/2018/09/rack-middleware/)
- [谈谈 Rack 的协议与实现](https://draveness.me/rack/)
- [rails_on_rack](https://guides.rubyonrails.org/rails_on_rack.html)
- [passenger-vs-puma](https://stackshare.io/stackups/passenger-vs-puma)
- [why-to-use-puma-in-production-for-your-rails-app](https://dev.to/anilmaurya/why-to-use-puma-in-production-for-your-rails-app-44ga)
- [thoughtbot rack](https://thoughtbot.com/upcase/videos/rack)
