class Song
  def self.populate!
    @songs = [
               {:title => "I'm Ready For You", :artist => "Drake", :like => true},
               {:title => "Friday", :artist => "Rebecca Black", :like => false},
               {:title => "99 Problems", :artist => "Jay-Z", :like => true},
               {:title => "You Be Killin' Em", :artist => "Fabolous", :like => true},
               {:title => "Believe", :artist => "Cher", :like => false}
             ]
    @songs.each do |song|
      begin
        self.create({:title => song[:title], :artist => song[:artist], :like => song[:like]})
      rescue => ex
        puts "Exception!"
        puts
        # raised below: puts ex.message
        raise ex
      end
    end
  end
end
