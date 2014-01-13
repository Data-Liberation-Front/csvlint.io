module ValidationHelper

  def error_and_warning_count(errors, warnings, options)
    # Generate string
    components = []
    components << pluralize(@errors.count, t(:error).titleize) unless @errors.empty?
    components << pluralize(@warnings.count, t(:warning).titleize) unless @warnings.empty?
    if components.empty?
      ''
    else
      # Wrap it up
      wrapper = options[:wrapper] || :span
      content_tag(wrapper, components.join(', '))
    end
  end

  def badge_markdown(url)
    %{[![#{t(:csv_status)}](#{validate_url(url: url, format: 'svg')})](#{validate_url(url: url)})}
  end
  
  def badge_textile(url)
    %{!#{validate_url(url: url, format: 'svg')}(#{t(:csv_status)})!:#{validate_url(url: url)}}
  end

  def badge_rdoc(url)
    %{{<img src="#{validate_url(url: url, format: 'svg')}" alt="#{t(:csv_status)}" />}[#{validate_url(url: url)}]}
  end

  def badge_html(url)
    %{<a href='#{validate_url(url: url)}'><img src="#{validate_url(url: url, format: 'svg')}" alt="#{t(:csv_status)}" /></a>}
  end

end
