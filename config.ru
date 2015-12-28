require_relative 'load_dependencies'

# map the controllers to routes
map('/api/v1/fitbit/auth'){ run Api::V1::FitbitAuthController }
map('/api/v1/fitbit/data'){ run Api::V1::FitbitDataController }
map('/'){ run LandingController }
