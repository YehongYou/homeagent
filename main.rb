
require 'sinatra'
# require 'sinatra/reloader'
# require 'pry'

require'./db_config'
require'./models/comment'
require'./models/message'
require'./models/property_purpose'
require'./models/property'
require'./models/user_type'
require'./models/user'
require'./models/image'

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

  # find unique gender from all messages
  all_messages2 = Message.all
  all_genders = []
  all_messages2.each do |each|
    all_genders << each.user.gender
  end
  @genders = all_genders.uniq

if params[:search_by_gender] != nil
  # @messages = Message.where(gender: params[:search_by_gender]).order('post_date DESC')
  @messages =[]
  all_messages2.each do |each_message|
    if each_message.user.gender == params[:search_by_gender]
       @messages << each_message
    end
  end
  @current_gender = params[:search_by_gender]
# else
#  #just get all messages
#   @messages = Message.order('post_date DESC')
end








   erb :messages_all
end

#  go to the create message form
get "/messages/new" do

  if logged_in?
     erb :new_message
  else
     erb :login
  end
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

  if logged_in?
     @message = Message.find(params[:id])
     @user = @message.user
     if @user == nil
       redirect to "/messages"
     end
     @comments = @message.comments
     erb :message_show
  else
     erb :login
  end
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
   redirect to "/messages/#{params[:message_id]}"
end

# delete the message in the database
delete "/messages/:message_id" do
  message = Message.find(params[:message_id])

  if message.comments != nil
      message.comments.each do |comment|
          comment.destroy
      end
  end

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

   @property_purposes = PropertyPurpose.all

   if params[:search_by_purpose_id] != nil
     @properties = Property.where(property_purpose_id: params[:search_by_purpose_id]).order('post_date DESC')
     @current_purpose = params[:search_by_purpose]
   end

  erb :properties_all
end

#go to the create new property form
get "/properties/new" do
  if logged_in?
    @property_purposes = PropertyPurpose.all
    erb :new_property
  else
    erb :login
  end
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
  # create a new image
    new_image = Image.new
    new_image.image_url = params[:input_image]
    new_image.property_id = Property.last.id
    new_image.save

  redirect to '/properties'
end


# show single property
get "/properties/:id" do
   if logged_in?
     @property = Property.find(params[:id])
     @user = @property.user
     @images = @property.images
     if @user == nil
       redirect to "/properties"
     end
     @comments = @property.comments
     erb :property_show
   else
     erb :login
   end
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

   image = Image.new
   image.image_url = params[:input_image]
   image.property_id = params[:property_id]
   image.save

   redirect to "/properties/#{params[:property_id]}"
end

# delete the property in the database
delete "/properties/:property_id" do
  property = Property.find(params[:property_id])

  if property.comments != nil
      property.comments.each do |each|
          each.destroy
      end
  end

  if property.images != nil
      property.images.each do |image|
          image.destroy
      end
  end

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

#=================== user part =======================
get "/register" do
   @note = "Email address"
   erb :register
end

# register a new user
post "/register/new" do
    user = User.new
    user.email = params[:input_email]
    user.password = params[:input_password]
    user.name = params[:input_name]
    user.gender = params[:input_gender]
    user.phone = params[:input_phone]
    user.occupation = params[:input_occupation]

    if User.all.size == 0
    user.user_type_id = 3  #set user as owner
    else
    user.user_type_id = 2 # set user as normal user
    end

    exist = false
    users = User.all
    users.each do |user|
       if user.email == params[:input_email]
          exist = true
       end
    end

    if !exist
      user.save
      erb :login
    else
      @note = "This email alread exist ! Try again~"
      erb :register
    end
end
# show the user account and all their post

get "/persion_account" do
   @user = User.find(session[:user_id])
   @properties = @user.properties
   @messages = @user.messages

   erb :user_account
end

# show all users

get '/users' do
   @owners = User.where(user_type_id: 3)
   @managers = User.where(user_type_id: 1)
   @users = User.where(user_type_id: 2)
   erb :user_all
end

# show single user details
get '/persion_account/:user_id' do
   @user = User.find(params[:user_id])
   erb :user_details
end

# edit persional user information form

get "/persion_account/:user_id/edit" do
    @user = User.find(params[:user_id])

    erb :user_edit
end

# edit persional user information

patch "/persion_account/edit" do
    @user = User.find(session[:user_id])
    @user.name = params[:input_name]
    @user.email = params[:input_email]
    @user.gender = params[:input_gender]
    @user.phone = params[:input_phone]
    @user.occupation = params[:input_occupation]
    if params[:input_password] != nil && params[:input_password] != ""
     @user.password = params[:input_password]
    end

    @user.save
    redirect "/persion_account/#{session[:user_id]}"
end






# change the normal user into manager
get '/users/:id' do
   user = User.find(params[:id])
   user.user_type_id = 1
   user.save
   redirect to '/users'
end

delete '/users/:id' do
   user = User.find(params[:id])

   if user.comments != nil
       user.comments.each do |each|
           each.destroy
       end
   end

   if user.messages != nil
       user.messages.each do |each|
           each.destroy
       end
   end

   if user.properties != nil
       user.properties.each do |each|
           each.destroy
       end
   end

   user.destroy
   redirect to '/users'
end

get '/users/revoke/:id' do
  user = User.find(params[:id])
  user.user_type_id = 2
  user.save
  redirect to '/users'
end

# get '/users/:id/details' do
#    @user = User.find(params[:id])
#    erb :user_details
# end

get '/about' do
  erb :about
end

post '/upload' do
  new_image = Image.new
  new_image.image_url = params[:image]
  new_image.save

  erb :about
end
