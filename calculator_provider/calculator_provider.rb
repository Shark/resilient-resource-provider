require 'ostruct'
require 'json'

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'httparty'

begin
  require 'pry'
rescue LoadError
end

if (host = ENV['CALCULATOR_HOST']) && (port = ENV['CALCULATOR_PORT'])
  calculator_host = host
  calculator_port = port
else
  fail 'I need calculator host and port configuration!'
end

config = OpenStruct.new(calculator_host: calculator_host,
                        calculator_port: calculator_port,
                        calculator_timeout: ENV['CALCULATOR_TIMEOUT'] || 2)

get '/' do
  'Calculator Provider'
end

get '/add' do
  begin
    x = Float(params.fetch('x'))
    y = Float(params.fetch('y'))
  rescue ArgumentError
    return 400
  end

  begin
    calculator_response = HTTParty.get("http://#{config.calculator_host}:#{config.calculator_port}/add?x=#{x}&y=#{y}",
                                       timeout: config.calculator_timeout)

    if calculator_response.code == 200
      add_result = JSON.parse(calculator_response.body)['result']
      response = { result: add_result }
      JSON.dump(response)
    else
      calculator_response.code
    end
  rescue HTTParty::Error
    502
  rescue Errno::ECONNREFUSED
    503
  rescue Net::ReadTimeout
    504
  end
end
