module Api
	module V1
		class FitbitAuthController < ApplicationController
			get '/' do
				json greeting: "Hello, your app is running!"
			end
		end
	end
end