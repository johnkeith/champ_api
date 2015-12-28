require 'rubygems'
require 'bundler'
require 'uri'
require 'net/http'
require 'json'
require 'rack/cors'

Bundler.require
Bundler.require(Sinatra::Base.environment)

# pull in the contents of /app dir
# must load the helpers/services modules first?
Dir.glob('./app/helpers/*.rb').each { |file| require file }
Dir.glob('./app/services/*.rb').each { |file| require file }
Dir.glob('./app/controllers/**/*.rb').each { |file| require file }
Dir.glob('./config/*.rb').each { |file| require file }