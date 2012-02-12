class HelloWorker
  def run
    name = params['name'] || 'world'
    puts "Hello #{name}!"
  end
end
