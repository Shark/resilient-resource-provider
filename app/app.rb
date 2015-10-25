require 'ostruct'
require 'json'

require 'rubygems'
require 'bundler/setup'
require 'sinatra'

begin
  require 'pry'
rescue LoadError
end

require_relative 'lib/calculator'

get '/' do
  haml :index
end

post '/' do
  begin
    x = Float(params.fetch('x'))
    y = Integer(params.fetch('y'))
  rescue ArgumentError
    return 400
  end

  calculator = Calculator.new
  result, debug = calculator.add(x, y)

  haml :index, locals: { result: result, debug: debug }
end
