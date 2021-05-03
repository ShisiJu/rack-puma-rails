# frozen_string_literal: true

require 'byebug'
APP = ->(env) { [200, {}, [env.inspect]] }

class PutsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    puts 'middleware 1 --- before request'
    response = @app.call(env)
    puts 'middleware 1 --- after response'
    response
  end
end

class PutsMiddleware2
  def initialize(app)
    @app = app
  end

  def call(env)
    puts 'middleware 2 --- before request'
    response = @app.call(env)
    puts 'middleware 2 --- after response'
    response
  end
end

# http://localhost:9292/hello_world
use PutsMiddleware
use PutsMiddleware2

run ->(env) { APP.call(env) }
