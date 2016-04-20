
require 'sinatra'
require 'sinatra/reloader'

require'./db_config'
require'./models/comment'
require'./models/message'
require'./models/property_purpose'
require'./models/property'
require'./models/user_type'
require'./models/user'

enable :sessions

helpers do

  def current_user
    User.find_by(id: session[:user_id])
  end

  def logged_in?
    !!current_user
  end

end

after do
  ActiveRecord::Base.connection.close  # instead of closing in every get do event
end

get '/session/new' do
  erb :login
end

post '/session' do
  user = User.find_by(email: params[:input_email])
  if user && user.authenticate(params[:input_password])
    #we are in and create a new session
    session[:user_id]= user.id
    #redirect to
    redirect to '/'
  else
    #stay at the login form
    erb :login
  end
end
# delete the session
get '/session/logout' do
   session[:user_id]=nil
   redirect to '/'
end
# ====================================================
get '/' do
  erb :index
end

get '/about' do
  erb :about
end

get '/login' do
  erb :login
end

# ============================ messages part ============================
#  display all messages
get '/messages' do
  #  find unique suburb from all messages
     all_messages = Message.all
     all_suburb = []
     all_messages.each do |each|
       all_suburb << each.suburb
     end
     @suburbs = all_suburb.uniq

   if params[:search_by_suburb] != nil
     @messages = Message.where(suburb: params[:search_by_suburb]).order('post_date DESC')
     @current_suburb = params[:search_by_suburb]
   else
    #just get all messages
     @messages = Message.order('post_date DESC')
   end

   erb :messages_all
end

#  go to the create message form
get "/messages/new" do
  erb :new_message
end

# post a new message into DATABASE
post "/messages" do
   new_message = Message.new
   new_message.suburb = params[:input_suburb]
   new_message.requirement = params[:input_requirement]
   new_message.post_date = Time.now
   new_message.user_id = session[:user_id]
   new_message.save

   redirect to '/messages'
end
# show single message
get "/messages/:id" do
   @message = Message.find(params[:id])
   @user = @message.user
   @comments = @message.comments
   erb :message_show
end


# go to the edit form
get "/messages/:message_id/edit" do
   @message = Message.find(params[:message_id])
   erb :message_edit
end

# edit the message into the database
patch "/messages/:message_id" do
   message = Message.find(params[:message_id])
   message.suburb = params[:input_suburb]
   message.requirement = params[:input_requirement]
   message.post_date = Time.now
   message.save
   redirect to '/messages'
end

# delete the message in the database
delete "/messages/:message_id" do
  message = Message.find(params[:message_id])
  message.destroy
  redirect to '/messages'
end

# ===================messages ~ comments================
post "/messages/:message_id/comments" do
   new_comment = Comment.new
   new_comment.message_id = params[:message_id]
   new_comment.user_id = session[:user_id]
   new_comment.content = params[:content]

  if new_comment.valid?
     new_comment.save
     redirect to "/messages/#{params[:message_id]}"
  else
    redirect to "/messages/#{params[:message_id]}"
  end
end

#===================properties part ====================
# display all properties
get '/properties' do

  #  find unique suburb from all properties
     all_properties = Property.all
     all_suburb = []
     all_properties.each do |each|
       all_suburb << each.suburb
     end
     @suburbs = all_suburb.uniq

   if params[:search_by_suburb] != nil
     @properties = Property.where(suburb: params[:search_by_suburb]).order('post_date DESC')
     @current_suburb = params[:search_by_suburb]
   else
    #just get all properties
     @properties = Property.order('post_date DESC')
   end
  erb :properties_all
end

#go to the create new property form
get "/properties/new" do
  @property_purposes = PropertyPurpose.all

  erb :new_property
end

# create a new property and save it into database
post '/properties' do
  new_property = Property.new
  new_property.kind = params[:input_kind]
  new_property.address = params[:input_address]
  new_property.suburb = params[:input_suburb]
  new_property.rent = params[:input_rent]
  new_property.description = params[:input_description]
  new_property.post_date = Time.now
  new_property.user_id = session[:user_id]
  new_property.property_purpose_id = params[:property_purpose_id]
  new_property.save

  redirect to '/properties'
end


# show single property
get "/properties/:id" do
   @property = Property.find(params[:id])
   @user = @property.user
   @comments = @property.comments
   erb :property_show
end


# go to the edit form
get "/properties/:property_id/edit" do
   @property_purposes = PropertyPurpose.all
   @property = Property.find(params[:property_id])
   erb :property_edit
end

# edit the property into the database
patch "/properties/:property_id" do
   property = Property.find(params[:property_id])
   property.kind = params[:input_kind]
   property.address = params[:input_address]
   property.suburb = params[:input_suburb]
   property.rent = params[:input_rent]
   property.description = params[:input_description]
   property.post_date = Time.now
   property.property_purpose_id = params[:property_purpose_id]
   property.save

   redirect to '/properties'
end

# delete the property in the database
delete "/properties/:property_id" do
  property = Property.find(params[:property_id])
  property.destroy
  redirect to '/properties'
end

# ====================== comments ~ property ================
post "/properties/:property_id/comments" do
   new_comment = Comment.new
   new_comment.property_id = params[:property_id]
   new_comment.user_id = session[:user_id]
   new_comment.content = params[:content]

  if new_comment.valid?
     new_comment.save
     redirect to "/properties/#{params[:property_id]}"
  else
    redirect to "/properties/#{params[:property_id]}"
  end
end
