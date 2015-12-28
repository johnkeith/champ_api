module FitbitApiHelpers
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