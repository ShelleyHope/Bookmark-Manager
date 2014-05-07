require	'sinatra'
require 'data_mapper'
require 'rack-flash'

use Rack::Flash

enable :sessions
 set :session_secret, 'my unique encryption key!'

env = ENV["RACK_ENV"] || "development"

# we're telling datamapper to use a postgres database on localhost. 
# The name will be "bookmark_manager_test" or "bookmark_manager_development" 
# depending on the environment

DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")


require './lib/link' # this needs to be done after datamapper is initialised
require './lib/tag'
require './lib/user'
require './lib/application'

# After declaring your models, you should finalise them
DataMapper.finalize

# However, the database tables don't exist yet. 
# Let's tell datamapper to create them
DataMapper.auto_upgrade!

get '/' do
  @links = Link.all
  erb :index
end

post '/links' do
  url = params["url"]
  title = params["title"]
  tags = params["tags"].split(" ").map do |tag|
  # this will either find this tag or create
  # it if it doesn't exist already
  Tag.first_or_create(:text => tag)
end
Link.create(:url => url, :title => title, :tags => tags)
redirect to('/')
end

get '/tags/:text' do
  tag = Tag.first(:text => params[:text])
  @links = tag ? tag.links : []
  erb :index
end


get	'/users/new' do
	@user = User.new
# note the view is in views/users/new.erb 
# we need the quotes because otherwise
# ruby would divide the symbol :users by the
# variable new (which makes no sense)
erb :"users/new"
end

post '/users' do
  @user = User.new(:email => params[:email], 
              :password => params[:password],
              :password_confirmation => params[:password_confirmation])  
   if @user.save
    session[:user_id] = @user.id
    redirect to('/')
  else
  flash[:notice] = "Sorry, your passwords don't match"
  erb :"users/new"
  end
end

 




