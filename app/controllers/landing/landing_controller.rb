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
    erb :index
  end
end