module ValidationHelper

  def error_and_warning_count(errors, warnings, options)
    # Generate string
    components = []
    components << pluralize(@result.errors.count, t(:error).titleize) unless @result.errors.empty?
    components << pluralize(@result.warnings.count, t(:warning).titleize) unless @result.warnings.empty?
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
        :linebreak        => line_break_strings[validator.line_breaks],
        :encoding         => validator.encoding,
        :content_type     => validator.content_type,
        :extension        => validator.extension,
        :row              => message.row,
        :column           => message.column,
        :type             => message.type,
        :min_length       => message.column ? validator.schema.fields[message.column].try(:constraints).try(:[], 'minLength') : nil,
        :max_length       => message.column ? validator.schema.fields[message.column].try(:constraints).try(:[], 'maxLength') : nil,
        :min_value        => message.column ? validator.schema.fields[message.column].try(:constraints).try(:[], 'minimum') : nil,
        :max_value        => message.column ? validator.schema.fields[message.column].try(:constraints).try(:[], 'maximum') : nil,
        :value            => message.content,
        :expected_header  => '',
        :header           => message.column ? validator.schema.fields[message.column].try(:name) : nil,
        :pattern          => message.column ? validator.schema.fields[message.column].try(:constraints).try(:[], 'pattern') : nil,
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
  
  def badge_markdown(id)
    %{[![#{t(:csv_status)}](#{validation_url(id: id, format: 'svg')})](#{validation_url(id: id)})}
  end
  
  def badge_textile(id)
    %{!#{validation_url(id: id, format: 'svg')}(#{t(:csv_status)})!:#{validation_url(id: id)}}
  end

  def badge_rdoc(id)
    %{{<img src="#{validation_url(id: id, format: 'svg')}" alt="#{t(:csv_status)}" />}[#{validation_url(id: id)}]}
  end

  def badge_html(id)
    %{<a href='#{validation_url(id: id)}'><img src="#{validation_url(id: id, format: 'svg')}" alt="#{t(:csv_status)}" /></a>}
  end

end
