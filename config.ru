require 'byebug'
APP = ->(env) { [200, {}, [env.inspect]] }
# http://localhost:9292/hello_world
run ->(env) { APP.call(env) }