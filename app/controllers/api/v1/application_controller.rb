module Api
	module V1
		class ApplicationController < Sinatra::Base
			# Sinatra configuration and settings applied to all subclassed controllers

			register Sinatra::JSON

			set :root, File.dirname('../../../../../..')

			use Rack::Cors do
		    allow do
		      origins '*'
		      resource '*', :headers => :any, :methods => [:get, :post, :options]
		    end
		  end

			configure do 
				set :views, "#{File.expand_path(settings.root, __FILE__)}/templates"

				CONFIG = YAML.load(File.open(File.expand_path(
					settings.root + '/config/config.yml', __FILE__)))
			end

			configure :development, :production do
		    enable :logging
		  end

		  # before '/*' do
		  	# looks like this blows up when coming from IOS - # maybe loosing the headers in the transferance to safari? / redirect from Fitbit

		  	# unless request.env['HTTP_SECRET'] == CONFIG[Sinatra::Base.environment][:secret]
			  # 	halt 500
			  # end
		  # end
		end
	end
end