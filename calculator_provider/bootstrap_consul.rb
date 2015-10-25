require 'rubygems'
require 'bundler/setup'

require 'diplomat'
require 'yaml'

Diplomat.configure do |config|
  config.url = ENV['CONSUL_HTTP_URL'] || (raise 'I need a consul http url!')
end

def bootstrap_recursive(hsh, path)
  hsh.each do |key, value|
    if value.is_a? Hash
      bootstrap_recursive(value, path+[key])
    else
      path_str = (path + [key]).join('/')

      begin
        Diplomat::Kv.get(path_str, nil, :return, :reject)
        Diplomat::Kv.put(path_str, value.to_s)
        puts "Put '#{value}' into #{path_str}."
      rescue Diplomat::KeyAlreadyExists
        puts "Skip #{path_str} because it already exists."
      end
    end
  end
end

bootstrap_kv = YAML.load_file(File.join(File.dirname(__FILE__), 'bootstrap_consul.yml'))
bootstrap_recursive(bootstrap_kv, [])
