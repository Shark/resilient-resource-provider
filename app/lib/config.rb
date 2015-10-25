class Config
  def self.service_name
    'calculator_provider'
  end

  def self.service_fqdn
    "#{service_name}.service.consul"
  end
end
