class RubyWorker

  attr_accessor :a, :b

  def run
    puts( { :a => a, :b => b }.to_json )
  end

end
