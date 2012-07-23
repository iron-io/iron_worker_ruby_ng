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
end
