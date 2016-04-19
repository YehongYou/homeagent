class User < ActiveRecord::Base
   has_secure_password
   belongs_to :user_type
   has_many :properties
   has_many :messages
   has_many :comments
end
