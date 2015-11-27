module Api
	module V1
		class FitbitDataController < ApplicationController
			helpers do
				def fitbit_config
					CONFIG[Sinatra::Base.environment][:fitbit]
				end

				def lifetime_stats_uri(user_id)
					"https://api.fitbit.com/1/user/#{user_id}/activities.json"
				end

				def lifetime_stats_request(user_id, access_token)				
					url = lifetime_stats_uri(user_id)
					uri = URI.parse(url)

					req = Net::HTTP::Get.new(uri.request_uri)
					req.initialize_http_header({ 'Authorization' => "Bearer #{access_token}" })

					res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |r| r.request(req) }
					res.body
				end
			end

			# http://localhost:9393/api/v1/fitbit/data/lifetime_stats
			get '/lifetime_stats' do
				json data: lifetime_stats_request(params['user_id'], params['access_token'])
			end
		end
	end
end