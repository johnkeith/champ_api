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

				def days_of_week_comparison_uri(user_id, date) 
					"https://api.fitbit.com/1/user/#{user_id}/activities/tracker/steps/date/#{date}/1y.json"
				end

				def lifetime_stats_request(user_id, access_token)				
					url = lifetime_stats_uri(user_id)

					base_request(url, access_token)
				end

				def days_of_week_comparison_request(user_id, access_token)
					date = Time.now.strftime('%Y-%m-%d')
					url = days_of_week_comparison_uri(user_id, date)

					base_request(url, access_token)
				end

				def base_request(url, access_token)
					uri = URI.parse(url)

					req = Net::HTTP::Get.new(uri.request_uri)
					req.initialize_http_header({ 'Authorization' => "Bearer #{access_token}" })

					res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |r| r.request(req) }
					res.body
				end

				def analyze_days_of_week_comparison_results(results)
					data = results['activities-tracker-steps']
					
					add_day_of_week_to_results!(data)

					data = group_data_by_day_of_week(data)

					day_sums = sum_steps_by_day_of_week(data)
					days_with_data = sum_days_of_week_with_valid_data(data)

					output = { average_steps_per_day: {}, year_totals_per_day: day_sums }

					day_sums.each do |day, sum|
						output[:average_steps_per_day][day] = sum / days_with_data[day] rescue 0
					end

					output
				end

				def add_day_of_week_to_results!(data)
					data.each do |r|
						r['day'] = Date.parse(r['dateTime']).strftime("%A")
					end
				end

				def group_data_by_day_of_week(data)
					data.group_by { |r| r['day'] }
				end

				def sum_steps_by_day_of_week(grouped_data)
					results = Hash.new(0)

					grouped_data.each { |day, values| results[day] = sum_values_of_results(values) }

					results
				end

				def sum_values_of_results(data)
					data.map { |r| r['value'].to_i rescue 0 }.sum
				end

				def sum_days_of_week_with_valid_data(grouped_data)
					results = Hash.new(0)

					grouped_data.each do |day, values| 
						values.each do |row|
							results[day] += 1 if row['value'].to_i != 0
						end
					end

					results
				end
			end

			# http://localhost:9393/api/v1/fitbit/data/lifetime_stats
			get '/lifetime_stats' do
				json data: JSON.parse(lifetime_stats_request(params['user_id'], params['access_token']))
			end

			# http://localhost:9393/api/v1/fitbit/data/days_of_week_comparison
			get '/days_of_week_comparison' do
				results = JSON.parse(days_of_week_comparison_request(params['user_id'], params['access_token']))
				results = analyze_days_of_week_comparison_results(results)

				json data: results
			end
		end
	end
end