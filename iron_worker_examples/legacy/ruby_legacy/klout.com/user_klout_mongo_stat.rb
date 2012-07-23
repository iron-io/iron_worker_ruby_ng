require 'mongoid'

class UserKloutMongoStat
  include Mongoid::Document
  field :username, type: String
  field :score, type: Float
  field :for_date, type: Time
end