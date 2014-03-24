require "nokogiri"
require "mechanize"
@browser = ['Linux Mozilla', 'Mac Mozilla', 'Mac Safari', 'Windows Mozilla', 'Windows IE 8', 'Windows IE 9'].sample
@mecha = Mechanize.new { |agent| agent.user_agent_alias = @browser}
page = @mecha.get("http://www.google.com")
raise "Not found" unless page.inspect.include? "Google"
raise "Wrong ruby version" unless RUBY_VERSION.start_with?('2.1')
