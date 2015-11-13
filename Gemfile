source "https://rubygems.org/"

gem "sinatra", "~> 1.4"
gem "sinatra-contrib", "~> 1.4"

group :development do
	gem "shotgun"
  gem "guard-bundler"
	gem 'guard-rack'
	gem 'guard-rspec'
end

group :test do
	gem "factory_girl"
  gem "rspec"
  gem "rack-test"
end

group :development, :test do
	gem "byebug"
	gem "pry"
end
