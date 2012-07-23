
class ModelGood

  attr_accessor :name, :position

  def to_json(*a)
    {
      'json_class'   => self.class.name,
      'data'         => { :name=>name, :position=>position }
    }.to_json(*a)
  end

  def self.json_create(o)
    model = new
    model.name = o['data']['name']
    model.position = o['data']['position']
    model
  end

end

