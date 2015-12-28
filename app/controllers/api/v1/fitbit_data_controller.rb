module Api
	module V1
		class FitbitDataController < ApplicationController
			include FitbitApiHelpers
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
		end
	end
end