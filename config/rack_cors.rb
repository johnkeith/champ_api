use Rack::Cors do
  allow do
    origins '*'

    resource '*',
      :headers => :any,
      :methods => [:post, :get, :options],
      :max_age => 0
  end

  allow do
    origins '*'
    resource '/public/*', :headers => :any, :methods => :get
  end
end