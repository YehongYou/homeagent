
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

# comments
post "/messages/:message_id/comments" do
   new_comment = Comment.new
   new_comment.find_house_id = params[:message_id]
   new_comment.user_id = session[:user_id]
   new_comment.content = params[:content]
   new_comment.save
   redirect to "/messages/#{params[:message_id]}"

end
