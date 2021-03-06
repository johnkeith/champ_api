require 'rubygems'
require 'bundler'
require 'uri'
require 'net/http'
require 'json'
require 'rack/cors'

Bundler.require
Bundler.require(Sinatra::Base.environment)

# pull in the contents of /app dir
Dir.glob('./app/**/*.rb').each { |file| require file }
Dir.glob('./config/*.rb').each { |file| require file }