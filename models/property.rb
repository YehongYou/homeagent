require 'carrierwave'
require 'carrierwave/orm/activerecord'

class MyUploader < CarrierWave::Uploader::Base
 storage :file

 # def store_dir
 #   "/public/"
 # end
end

class Property < ActiveRecord::Base
   belongs_to :user
   belongs_to :property_purpose
   has_many :comments
   mount_uploader :image_url, MyUploader
end
