require 'ostruct'
require 'json'

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'httparty'
require 'diplomat'

begin
  require 'pry'
rescue LoadError
end

require_relative 'lib/circuit_breaker'

if (host = ENV['CALCULATOR_HOST']) && (port = ENV['CALCULATOR_PORT'])
  calculator_host = host
  calculator_port = port
else
  fail 'I need calculator host and port configuration!'
end

config = OpenStruct.new(calculator_host: calculator_host,
                        calculator_port: calculator_port,
                        calculator_timeout: ENV['CALCULATOR_TIMEOUT'] || 2)

Diplomat.configure do |config|
  config.url = ENV['CONSUL_HTTP_URL'] || (raise 'I need a consul http url!')
end

circuit_breaker = CircuitBreaker.new(failure_threshold: ENV['FAILURE_THRESHOLD'],
                                     reset_timeout: ENV['RESET_TIMEOUT'])

get '/' do
  'Calculator Provider'
end

get '/add' do
  return 502 if circuit_breaker.fail_immediately?

  begin
    x = Float(params.fetch('x'))
    y = Float(params.fetch('y'))
  rescue ArgumentError
    return 400
  end

  result = nil

  circuit_breaker.operate do
    begin
      calculator_response = HTTParty.get("http://#{config.calculator_host}:#{config.calculator_port}/add?x=#{x}&y=#{y}",
                                         timeout: config.calculator_timeout)

      if calculator_response.code == 200
        add_result = JSON.parse(calculator_response.body)['result']
        response = { result: add_result }
        result = JSON.dump(response)
      else
        result = calculator_response.code
        raise calculator_resposne.code
      end
    rescue HTTParty::Error => e
      result = 502
      raise e
    rescue Errno::ECONNREFUSED => e
      result = 503
      raise e
    rescue Net::ReadTimeout => e
      result = 504
      raise e
    end
  end

  return result
end

get '/health' do
  circuit_breaker.update

  case circuit_breaker.state
  when :closed
    status 200
  when :half_open, :open
    status 429
  end

  JSON.dump(state: circuit_breaker.state,
            failure_count: circuit_breaker.failure_count,
            last_failed: circuit_breaker.last_failed)
end
