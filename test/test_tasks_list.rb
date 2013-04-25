require_relative 'helpers'

class TestTaskList < IWNGTest

  def test_task_list

    tasks = client.tasks.list()
    code_names = {}
    tasks.each do |t|
      puts "#{t.code_name} - #{t.status}"
      code_names[t.code_name] ||= 0
      code_names[t.code_name] += 1
    end
    puts "num codes: #{code_names.size}"

    assert code_names.size > 0

    tasks = client.tasks.list(:code_name=>"hello")
    code_names = {}
    tasks.each do |t|
      p t.code_name
      code_names[t.code_name] ||= 0
      code_names[t.code_name] += 1
    end
    puts "num codes: #{code_names.size}"

  end

end
