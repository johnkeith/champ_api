module Api
	module V1
		class ApplicationController < Sinatra::Base
			# Sinatra configuration and settings applied to all subclassed controllers

			register Sinatra::JSON

			configure :development, :production do
		    enable :logging
		  end
		end
	end
end