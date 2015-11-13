module Api
	module V1
		class ApplicationController < Sinatra::Base
			# Sinatra configuration and settings applied to all subclassed controllers

			register Sinatra::JSON

			set :root, File.dirname('../../../../../..')
			
			configure do 
				CONFIG = YAML.load(File.open(File.expand_path(
					settings.root + '/config/config.yml', __FILE__)))
			end

			configure :development, :production do
		    enable :logging
		  end
		end
	end
end