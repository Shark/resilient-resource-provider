require 'ostruct'
require 'json'

require 'rubygems'
require 'bundler/setup'
require 'sinatra'

begin
  require 'pry'
rescue LoadError
end

config = OpenStruct.new(fail_chance: 0.5, fail_timeout: 1)

get '/' do
  haml :index, locals: { config: config }
end

post '/' do
  begin
    fail_chance = Float(params.fetch('fail_chance'))
    fail_timeout = Integer(params.fetch('fail_timeout'))
  rescue ArgumentError
    return 400
  end

  config.fail_chance = fail_chance
  config.fail_timeout = fail_timeout

  redirect back
end

get '/add' do
  return goto_fail(config.fail_timeout) if should_fail?(config.fail_chance)

  begin
    x = Float(params.fetch('x'))
    y = Float(params.fetch('y'))
  rescue ArgumentError
    return 400
  end

  response = { result: x + y }
  JSON.dump(response)
end

def should_fail?(fail_chance)
  Random.rand <= fail_chance
end

def goto_fail(fail_timeout)
  sleep fail_timeout
  500
end
