require 'bundler'
require 'dotenv'
Bundler.require
require './app'
require './app.rb'

Dotenv.load

Cloudinary.config do |config|
  config.cloud_name = ENV['morimo-']
  config.api_key = ENV['792773679698251']
  config.api_secret = ENV['pkP33Hn57yMNLGlDySGrvIkO1W8']

  config.secure = true
  config.cdn_subdomain = true
end


run Sinatra::Application