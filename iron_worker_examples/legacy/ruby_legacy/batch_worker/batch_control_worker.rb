# This is the worker we'll schedule every X hours that will simply go through the users in our database
# and queue up a second worker for each of them.
#
# This assumes you are using ActiveRecord or SimpleRecord and you have a User model.

require 'iron_worker'

class BatchWorker < IronWorker::Base

  merge_worker "something_with_user_worker", "SomethingWithUserWorker"

  def run

    @users = User.find(:all)
    @users.each do |user|
      user_worker = SomethingWithUserWorker.new
      user_worker.user_id = user.id
      user_worker.queue
    end

  end

end