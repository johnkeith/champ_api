module Api
	module V1
		class FitbitAuthController < ApplicationController
			helpers do
				def fitbit_config
					CONFIG[Sinatra::Base.environment][:fitbit]
				end

				def fitbit_auth_url(state)				
					url = fitbit_config[:oauth_authorization_uri]
					uri = URI.parse(url)
					
					redirect_uri = state ? state : fitbit_config[:oauth_redirect_uri]

					uri.query = URI.encode_www_form(
						client_id: fitbit_config[:client_id],
						response_type: 'code',
						scope: 'activity heartrate profile',
						redirect_uri: redirect_uri)
					
					uri.to_s
				end

				def fitbit_access_token_request(code, state)
					url = fitbit_config[:oauth_refresh_token_uri]
					uri = URI.parse(url)
					
					redirect_uri = state ? state : fitbit_config[:oauth_redirect_uri]

					uri.query = URI.encode_www_form(
						client_id: fitbit_config[:client_id],
						grant_type: 'authorization_code',
						redirect_uri: redirect_uri,
						code: code)

					req = Net::HTTP::Post.new(uri.request_uri)
					req.basic_auth fitbit_config[:client_id], fitbit_config[:client_secret]

					res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |r| r.request(req) }
					res.body
				end

				def fitbit_refresh_token_request(token)
					url = fitbit_config[:oauth_refresh_token_uri]
					uri = URI.parse(url)
					
					uri.query = URI.encode_www_form(
						grant_type: 'refresh_token',
						refresh_token: token)

					req = Net::HTTP::Post.new(uri.request_uri)
					req.basic_auth fitbit_config[:client_id], fitbit_config[:client_secret]

					res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |r| r.request(req) }
					res.body
				end
			end

			# http://localhost:9393/api/v1/fitbit/auth
			get '/' do
				redirect fitbit_auth_url(params['state'])
			end

			# this would be used by a completely web-based client
			get '/redirect' do
				json data: JSON.parse(fitbit_access_token_request(params['code'], params['state']))
			end

			# this is used in the mobile app
			post '/' do
				json data: JSON.parse(fitbit_access_token_request(params['code'], params['state']))
			end

			post '/refresh' do
				json data: JSON.parse(fitbit_refresh_token_request(params['refresh_token']))
			end
		end
	end
end