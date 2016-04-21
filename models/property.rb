class Property < ActiveRecord::Base
   has_many :images
   belongs_to :user
   belongs_to :property_purpose
   has_many :comments
end
