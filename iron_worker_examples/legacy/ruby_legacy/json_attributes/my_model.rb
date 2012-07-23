class MyModel

  attr_accessor :name, :age

  def to_json(*a)
    {
      'json_class'   => self.class.name,
      'data'         => { :name=>name, :age=>age }
    }.to_json(*a)
  end

  def self.json_create(o)
    puts 'json_create'
    p o
    mm = new
    mm.name = o['data']['name']
    mm.age = o['data']['age']
    mm
  end

end
