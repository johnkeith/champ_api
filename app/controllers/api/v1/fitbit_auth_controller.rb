module Api
	module V1
		class FitbitAuthController < ApplicationController
			helpers do
				def fitbit_config
					CONFIG[Sinatra::Base.environment][:fitbit]
				end

				def external_fitbit_auth_url					
					url = fitbit_config[:oauth_authorization_uri]
					uri = URI.parse(url)
					
					uri.query = URI.encode_www_form(
						client_id: fitbit_config[:client_id],
						response_type: 'code',
						scope: 'activity heartrate profile',
						redirect_uri: fitbit_config[:oauth_redirect_uri])
					
					uri.to_s
				end

				def external_fitbit_access_token_request(code)
					url = fitbit_config[:oauth_refresh_token_uri]
					uri = URI.parse(url)
					
					uri.query = URI.encode_www_form(
						client_id: fitbit_config[:client_id],
						grant_type: 'authorization_code',
						redirect_uri: fitbit_config[:oauth_redirect_uri],
						code: code)

					req = Net::HTTP::Post.new(uri.request_uri)
					req.basic_auth fitbit_config[:client_id], fitbit_config[:client_secret]

					res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |r| r.request(req) }
					res.body
				end
			end

			# http://localhost:9393/api/v1/fitbit/auth
			get '/' do
				redirect external_fitbit_auth_url
			end

			get '/redirect' do
				json data: JSON.parse(external_fitbit_access_token_request(params['code']))
			end
		end
	end
end