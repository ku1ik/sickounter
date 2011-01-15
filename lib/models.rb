require "mongoid"

Mongoid.configure do |config|
  file_name = File.join(File.dirname(__FILE__), "..", "config", "mongoid.yml")
  settings = YAML.load(ERB.new(File.new(file_name).read).result)

  config.from_hash(settings[ENV['RACK_ENV']])
end

class Domain
  include Mongoid::Document
  field :name
  embeds_many :downloads
end

class Download
  include Mongoid::Document
  field :path
  field :count, :type => Integer, :default => 0
  embedded_in :domain, :inverse_of => :downloads
end
