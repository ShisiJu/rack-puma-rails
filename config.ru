# frozen_string_literal: true

require 'byebug'
APP = ->(env) { [200, {}, [env.inspect]] }

class PutsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    puts 'PutsMiddleware --- before request'
    response = @app.call(env)
    puts 'PutsMiddleware --- after response'
    response
  end
end

# http://localhost:9292/hello_world
use PutsMiddleware
run ->(env) { APP.call(env) }
