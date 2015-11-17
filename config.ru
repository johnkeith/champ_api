require_relative 'load_dependencies'
require_relative 'config/rack_cors.rb'

# map the controllers to routes
map('/api/v1/fitbit/auth'){ run Api::V1::FitbitAuthController }
