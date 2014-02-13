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

  def message_variables(validator, message)
    line_break_strings = {
      "\r" => "CR",
      "\n" => "LF",
      "\r\n" => "CR-LF",
    }
    variables = {
      :linebreak => line_break_strings[validator.line_breaks],
      :encoding => validator.encoding,
      :content_type => validator.content_type,
      :extension => validator.extension,
      :row => message.row,
      :column => message.column,
      :type => message.type,
      :content => message.content
    }
    if validator.headers
      validator.headers.each do |k,v|
        key = "header_#{k.gsub("-", "_")}".to_sym
        variables[key] = v
      end
    end
    variables
  end
  
  def extra_guidance(validator, message)
    extra = []
    extra << :old_content_type if message.type == :wrong_content_type && validator.content_type == "text/comma-separated-values"
    extra << :s3_upload if message.type == :wrong_content_type && validator.headers["Server"] = "AmazonS3"
    return extra
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
