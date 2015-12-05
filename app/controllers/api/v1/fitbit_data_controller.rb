module Api
	module V1
		class FitbitDataController < ApplicationController
			# /api/v1/fitbit/data/lifetime_stats
			get '/lifetime_stats' do
				json data: JSON.parse(lifetime_stats_request(params['user_id'], params['access_token']))
			end

			# /api/v1/fitbit/data/days_of_week_comparison
			get '/days_of_week_comparison' do
				results = JSON.parse(days_of_week_comparison_request(params['user_id'], params['access_token']))
				results = group_and_analyze_data_at_key_by_day_of_week(results, 'activities-tracker-steps', 0)

				json data: results
			end

			# /api/v1/fitbit/data/minutes_sedentary_comparison
			get '/minutes_sedentary_comparison' do
				results = JSON.parse(minutes_sedentary_for_year_request(params['user_id'], params['access_token']))
				results = group_and_analyze_data_at_key_by_day_of_week(results, 'activities-tracker-minutesSedentary', 1440)


				json data: results
			end

			# /api/v1/fitbit/data/minutes_active_comparison
			get '/minutes_active_comparison' do
				results_light_activity = JSON.parse(minutes_lightly_active_for_year_request(params['user_id'], params['access_token']))
				results_light_activity = group_and_analyze_data_at_key_by_day_of_week(results_light_activity, 'activities-tracker-minutesLightlyActive', 0)

				results_moderate_activity = JSON.parse(minutes_moderately_active_for_year_request(params['user_id'], params['access_token']))
				results_moderate_activity = group_and_analyze_data_at_key_by_day_of_week(results_moderate_activity, 'activities-tracker-minutesFairlyActive', 0)

				results_intense_activity = JSON.parse(minutes_intense_active_for_year_request(params['user_id'], params['access_token']))
				results_intense_activity = group_and_analyze_data_at_key_by_day_of_week(results_intense_activity, 'activities-tracker-minutesVeryActive', 0)

				results_moderate_and_intense_totals = sum_values_of_week_hashes(results_moderate_activity, results_intense_activity)
				results_totals = sum_values_of_week_hashes(results_light_activity, results_moderate_activity, results_intense_activity)
				

				json data: { 
					light_activity: results_light_activity,
					moderate_activity: results_moderate_activity,
					intense_activity: results_intense_activity,
					year_totals_per_day: results_totals,
					year_totals_moderate_and_intense: results_moderate_and_intense_totals
				}
			end

			helpers do
				### request functions

				def fitbit_config
					CONFIG[Sinatra::Base.environment][:fitbit]
				end

				def minutes_intense_active_for_year_uri(user_id, date)
					"https://api.fitbit.com/1/user/#{user_id}/activities/tracker/minutesVeryActive/date/#{date}/1y.json"
				end

				def minutes_intense_active_for_year_request(user_id, access_token)
					date = Time.now.strftime('%Y-%m-%d')
					url = minutes_intense_active_for_year_uri(user_id, date)

					base_request(url, access_token)
				end

				def minutes_moderately_active_for_year_uri(user_id, date)
					"https://api.fitbit.com/1/user/#{user_id}/activities/tracker/minutesFairlyActive/date/#{date}/1y.json"
				end

				def minutes_moderately_active_for_year_request(user_id, access_token)
					date = Time.now.strftime('%Y-%m-%d')
					url = minutes_moderately_active_for_year_uri(user_id, date)

					base_request(url, access_token)
				end

				def minutes_lightly_active_for_year_uri(user_id, date)
					"https://api.fitbit.com/1/user/#{user_id}/activities/tracker/minutesLightlyActive/date/#{date}/1y.json"
				end

				def minutes_lightly_active_for_year_request(user_id, access_token)
					date = Time.now.strftime('%Y-%m-%d')
					url = minutes_lightly_active_for_year_uri(user_id, date)

					base_request(url, access_token)
				end

				def minutes_sedentary_for_year_uri(user_id, date)
					"https://api.fitbit.com/1/user/#{user_id}/activities/tracker/minutesSedentary/date/#{date}/1y.json"
				end

				def minutes_sedentary_for_year_request(user_id, access_token)
					date = Time.now.strftime('%Y-%m-%d')
					url = minutes_sedentary_for_year_uri(user_id, date)

					base_request(url, access_token)
				end

				def lifetime_stats_uri(user_id)
					"https://api.fitbit.com/1/user/#{user_id}/activities.json"
				end

				def lifetime_stats_request(user_id, access_token)				
					url = lifetime_stats_uri(user_id)

					base_request(url, access_token)
				end

				def days_of_week_comparison_uri(user_id, date) 
					"https://api.fitbit.com/1/user/#{user_id}/activities/tracker/steps/date/#{date}/1y.json"
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

				### analysis of data from Fitbit API

				def group_and_analyze_data_at_key_by_day_of_week(results, key, remove_value=nil)
					data = group_data_at_key_by_day_of_week(results, key)

					day_sums = sum_values_by_day_of_week(data, remove_value)
					days_with_data = sum_days_of_week_with_valid_data(data, remove_value)

					group_output_averages_and_totals(day_sums, days_with_data)
				end

				def group_data_at_key_by_day_of_week(results, key)
					data = results[key]
					
					add_day_of_week_to_results!(data)

					group_data_by_day_of_week(data)
				end				

				def add_day_of_week_to_results!(data)
					data.each do |r|
						r['day'] = Date.parse(r['dateTime']).strftime("%A")
					end
				end

				def group_data_by_day_of_week(data)
					data.group_by { |r| r['day'] }
				end

				def sum_values_by_day_of_week(grouped_data, remove_value=nil)
					results = Hash.new(0)

					grouped_data.each { |day, values| results[day] = sum_values_of_results(values, remove_value) }

					results
				end

				def sum_values_of_results(data, remove_value=nil)
					data.map do |r|
						value = r['value'].to_i
						begin
							(remove_value && value == remove_value) ? 0 : value
						rescue 
							0
						end
					end.sum
				end

				def sum_days_of_week_with_valid_data(grouped_data, invalid_value=0)
					results = Hash.new(0)

					grouped_data.each do |day, values| 
						values.each do |row|
							results[day] += 1 if row['value'].to_i != invalid_value
						end
					end

					results
				end

				def group_output_averages_and_totals(day_sums, days_with_data)
					output = { averages_per_day: {}, year_totals_per_day: day_sums }

					day_sums.each do |day, sum|
						output[:averages_per_day][day] = sum / days_with_data[day] rescue 0
					end

					output
				end

				def sum_values_of_week_hashes(*week_hashes)
					output = Hash.new(0)

					week_hashes.each do |week_hash|
						week_hash[:averages_per_day].each do |day, value|
							output[day] += value || 0
						end
					end

					output
				end
			end
		end
	end
end