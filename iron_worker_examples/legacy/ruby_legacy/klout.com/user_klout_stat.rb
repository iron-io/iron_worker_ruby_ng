class UserKloutStat < SimpleRecord::Base
  has_strings :username
  has_ints :score
  has_dates :for_date
end