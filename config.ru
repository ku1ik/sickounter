require "bundler"
Bundler.setup

require File.join(File.dirname(__FILE__), "lib", "app")

run Sinatra::Application
