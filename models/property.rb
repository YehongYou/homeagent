class Property < ActiveRecord::Base
   belongs_to :user
   belongs_to :property_purpose
   has_many :comments
end
