require'pry'

require'./db_config'
require'./models/comment'
require'./models/message'
require'./models/property_purpose'
require'./models/property'
require'./models/user_type'
require'./models/user'
require'./models/image'
ActiveRecord::Base.logger = Logger.new(STDERR)# show the sql in console

binding.pry
