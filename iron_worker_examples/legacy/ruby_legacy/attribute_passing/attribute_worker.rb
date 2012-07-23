
require 'iron_worker'
require 'json'
require 'date'
 
class AttributeWorker < IronWorker::Base

  merge_gem 'chronic'

  attr_accessor :fixnum_arg, :floatnum_arg, :array_arg, :string_arg, :string_hash_arg,
                :hash_arg, :symbol_arg, :time_arg, :time_string_arg, :time_int_arg

  def run
    
    log "\n"
    log "@fixnum_arg: #{fixnum_arg}  [#{fixnum_arg.class}]" 
    log "@floatnum_arg: #{floatnum_arg}  [#{floatnum_arg.class}]" 
    log "@array_arg: #{array_arg}  [#{array_arg.class}]" 

    log "\n@string_arg: #{string_arg}  [#{string_arg.class}]" 
    
    string_hash_conv = JSON.parse(string_hash_arg)
    log "@string_hash_arg: #{string_hash_arg}  [#{string_hash_arg.class}]" 
    log "  @string_hash_arg (conv): #{string_hash_conv}  [#{string_hash_conv.class}]"     
 
    log "\n@hash_arg: #{hash_arg}  [#{hash_arg.class}]" 
    log "@symbol_arg: #{symbol_arg}  [#{symbol_arg.class}]"
    
    log "\n@time_arg: #{time_arg}  [#{time_arg.class}]"
 
    time1 = Chronic.parse(time_string_arg)   
    log "\n@time_string_arg: #{time_string_arg}  [#{time_string_arg.class}]"
    log "  @time_string_arg (conv): #{time1}  [#{time1.class}]"

    time2 = Time.at(time_int_arg).utc   
    log "@time_int_arg: #{time_int_arg} [#{time_int_arg.class}]"    
    log "  @time_int_arg (conv): #{time2} [#{time2.class}]"
    log "\n"

  end

end
