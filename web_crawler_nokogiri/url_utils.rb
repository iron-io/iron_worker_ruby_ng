module UrlUtils
  def relative?(url)
    url.match(/^http/) ? false : true
  end

  def make_absolute(potential_base, relative_url)
    if relative_url.match(/^\//)
      create_absolute_url_from_base(potential_base, relative_url)
    else
      create_absolute_url_from_context(potential_base, relative_url)
    end
  end

  def urls_on_same_domain?(url1, url2)
    get_domain(url1) == get_domain(url2)
  end

  def get_domain(url)
    remove_extra_paths(url)
  end

  private

  def create_absolute_url_from_base(potential_base, relative_url)
    remove_extra_paths(potential_base) + relative_url
  end

  def remove_extra_paths(potential_base)
    index_to_start_slash_search = potential_base.index('://')+3
    index_of_first_relevant_slash = potential_base.index('/', index_to_start_slash_search)
    if index_of_first_relevant_slash != nil
      return potential_base[0, index_of_first_relevant_slash]
    end
    potential_base
  end

  def create_absolute_url_from_context(potential_base, relative_url)
    if potential_base.match(/\/$/)
      absolute_url = potential_base+relative_url
    else
      last_index_of_slash = potential_base.rindex('/')
      if potential_base[last_index_of_slash-2, 2] == ':/'
        absolute_url = potential_base+'/'+relative_url
      else
        last_index_of_dot = potential_base.rindex('.')
        if last_index_of_dot < last_index_of_slash
          absolute_url = potential_base+'/'+relative_url
        else
          absolute_url = potential_base[0, last_index_of_slash+1] + relative_url
        end
      end
    end
    absolute_url
  end
  def open_url(url)
    url_object = nil
    begin
      url_object = open(url)
    rescue
      puts "Unable to open url: " + url
    end
    url_object
  end

  def update_url_if_redirected(url, url_object)
    if url != url_object.base_uri.to_s
      return url_object.base_uri.to_s
    end
    url
  end

  def parse_url(url_object)
    doc = nil
    begin
      doc = Nokogiri::HTML(url_object)
    rescue
      puts 'Could not parse url: ' + url_object.base_uri.to_s
    end
    puts 'Crawling url ' + url_object.base_uri.to_s
    doc
  end

  def find_urls_on_page(parsed_url, current_url)
    urls_list = []
    begin
      parsed_url.search('a[@href]').map do |x|
        new_url = x['href'].split('#')[0]
        unless new_url == nil
          if relative?(new_url)
            new_url = make_absolute(current_url, new_url)
          end
          urls_list.push(new_url)
        end
      end
    rescue
      puts "could not find links"
    end
    urls_list
  end

end
