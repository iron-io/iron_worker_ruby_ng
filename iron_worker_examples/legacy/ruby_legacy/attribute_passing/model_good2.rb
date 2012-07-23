
class ModelGood2

  attr_accessor :name, :position, :bat_ave
  
  def to_json(*a)
    hash_data = {}
    self.instance_variables.each do |var|
      hash_data[var] = self.instance_variable_get var
    end
 
    hash = {}
    hash['json_class'] = self.class.name
    hash['data'] = hash_data
    hash.to_json(*a)
  end
  
  def self.json_create(a)   
    model = new
    a["data"].each do |var, val|
      model.instance_variable_set var, val
    end
    model
  end

end

