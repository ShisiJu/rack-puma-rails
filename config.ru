require 'byebug'
require_relative 'app'

run ->(env) { APP.call(env) }