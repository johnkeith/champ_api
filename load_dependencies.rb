require 'rubygems'
require 'bundler'

Bundler.require
Bundler.require(Sinatra::Base.environment)

# pull in the contents of /app dir
Dir.glob('./app/**/*.rb').each { |file| require file }