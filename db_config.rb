require 'active_record'

options = {
  adapter:'postgresql',
  database:'homeagent'
}

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || options)
