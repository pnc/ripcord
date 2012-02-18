require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'mongoid'
require 'haml'
require 'active_support'
require 'action_view'
require 'octokit'
require 'oauth2'

CLIENT_ID = ENV["OAUTH_CLIENT_ID"] || "0717df89dbd037eb17e2"
CLIENT_SECRET = ENV["OAUTH_CLIENT_SECRET"] || "223f82069fcedc0598cf837d3e7b426be4a64c88"

# MongoDB configuration
Mongoid.configure do |config|
  if ENV['MONGOHQ_URL']
    conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
    uri = URI.parse(ENV['MONGOHQ_URL'])
    config.master = conn.db(uri.path.gsub(/^\//, ''))
  else
    config.master = Mongo::Connection.from_uri("mongodb://localhost:27017").db('test')
  end
end

class Authorization
  include Mongoid::Document
  field :token, :type => String
  
  def self.token=(_token)
    c = first || new()
    c.token = _token
    c.save
  end
  
  def self.token
    if first && first.token
      first.token
    else
      nil
    end
  end
  
  def self.github
    if self.token
      Octokit::Client.new(:oauth_token => Authorization.token)
    else
      nil
    end
  end
end

class Application
  include Mongoid::Document
  embeds_many :deploys
  field :name, :type => String
  field :repository, :type => String
  default_scope ascending(:name)
  
  def self.[](name)
    where(:name => name).first || new({:name => name})
  end
end

class Deploy
  include Mongoid::Document
  embedded_in :application
  
  field :sha, :type => String
  field :author_email, :type => String
  field :commit_message, :type => String
  field :deployed_at, :type => DateTime
  
  default_scope ascending(:deployed_at)
  
  before_create :set_time
  def set_time
    self.deployed_at = DateTime.now
  end
  
  def commit_message
    if self.application.repository.present?
      self[:commit_message]
    else
      "not available"
    end
  end
end

# Controllers
get '/' do
  apps = Application.all
  haml :index, :locals => {:apps => apps, :github => Authorization.github}
end

post '/' do
  puts "App is: #{params[:app]}"
  app = Application[params[:app]]
  deploy = Deploy.new :sha => params[:head_long],
                      :author_email => params[:user]
  app.deploys << deploy
  deploy.save
  app.save
end

put '/apps' do
  app = Application[params[:id]]
  app.repository = params[:value]
  app.save
  app.repository
end

get '/authorize' do
  redirect "https://github.com/login/oauth/authorize?client_id=#{CLIENT_ID}&scope=repo"
end

get '/oauth' do
  client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET, :site => 'https://github.com', :token_url => '/login/oauth/access_token')
  token = client.auth_code.get_token(params[:code])
  Authorization.token = token.token
  redirect '/'
end