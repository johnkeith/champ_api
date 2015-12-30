class LandingController < Sinatra::Base
  set :root, File.dirname('../../../../..')

  configure do 
    set :views, "#{File.expand_path(settings.root, __FILE__)}/templates"

    CONFIG = YAML.load(File.open(File.expand_path(
      settings.root + '/config/config.yml', __FILE__)))
  end

  configure :development, :production do
    enable :logging
  end

  get '/' do
    erb :landing_layout, layout: false do
      erb :landing_index
    end
  end

  get '/signed_up' do
    erb :landing_layout, layout: false do
      erb :landing_signed_up
    end
  end
end