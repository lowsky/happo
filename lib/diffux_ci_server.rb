require 'tilt/erubis' # used by sinatra, required to avoid thread-safe warning
require 'sinatra/base'
require 'yaml'
require 'diffux_ci_utils'
require 'diffux_ci_action'

class DiffuxCIServer < Sinatra::Base
  configure do
    enable :static
    set :port, DiffuxCIUtils.config['port']
  end

  get '/' do
    @config = DiffuxCIUtils.config
    erb :index
  end

  get '/debug' do
    @config = DiffuxCIUtils.config
    erb :debug
  end

  get '/review' do
    @snapshots = DiffuxCIUtils.current_snapshots
    erb :review
  end

  get '/resource' do
    file = params[:file]
    if file.start_with? 'http'
      redirect file
    else
      send_file file
    end
  end

  post '/reject' do
    DiffuxCIAction.new(params[:description], params[:viewport]).reject
    redirect back
  end

  post '/approve' do
    DiffuxCIAction.new(params[:description], params[:viewport]).approve
    redirect back
  end

  run!
end
