class Song
  include MongoMapper::Document
  key :title, String
  key :artist, String
  key :like, Boolean
end
