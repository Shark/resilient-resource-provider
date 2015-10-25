require 'json'
require 'httparty'
require_relative 'config'

class Calculator
  def add(x, y)
    host, port = consul_resolve(Config::service_fqdn)
    host = "docker" if ENV['RACK_ENV'] != 'production' && host.to_s == "172.17.42.1"

    url = "http://#{host}:#{port}/add?x=#{x}&y=#{y}"
    provider_response = HTTParty.get(url)

    if provider_response.code == 200
      add_result = JSON.parse(provider_response.body)['result']
      return add_result, ["Successful response from #{host}:#{port}"]
    else
      return nil, ["Error response (code: #{provider_response.code}) from #{host}:#{port}"]
    end
  end

  private

  # source: https://aws.amazon.com/de/blogs/compute/service-discovery-via-consul-with-amazon-ecs/
  def consul_resolve(service_fqdn)
    if ENV['RACK_ENV'] != 'production'
      resolver = Resolv::DNS.open(nameserver: 'docker',
                                  search: '',
                                  ndots: 1)
    else
      resolver = Resolv::DNS.open
    end

    record = resolver.getresource(service_fqdn, Resolv::DNS::Resource::IN::SRV)

    return resolver.getaddress(record.target), record.port
  end
end
