require 'bundler'
require 'dotenv'
Bundler.require
require './app'
require './app.rb'

Dotenv.load

Cloudinary.config do |config|
  config.cloud_name = 'morimo-'
  config.api_key = '792773679698251'
  config.api_secret = 'pkP33Hn57yMNLGlDySGrvIkO1W8'
  config.secure = true
  config.cdn_subdomain = true
end


run Sinatra::Application