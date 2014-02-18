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
        :linebreak        => line_break_strings[validator.line_breaks],
        :encoding         => validator.encoding,
        :content_type     => validator.content_type,
        :extension        => validator.extension,
        :row              => message.row,
        :column           => message.column,
        :type             => message.type,
        :min_length       => message.column ? validator.schema.fields[message.column].try(:constraints).try(:[], 'minLength') : nil,
        :max_length       => message.column ? validator.schema.fields[message.column].try(:constraints).try(:[], 'maxLength') : nil,
        :value            => message.content,
        :range_constraint => message.column ? range_text(validator.schema.fields[message.column].try(:constraints).try(:[], 'minimum'), validator.schema.fields[message.column].try(:constraints).try(:[], 'maximum')) : nil,
        :range_violation =>
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

  def range_text lower, upper
    return t(:range_min_max, lower: lower, upper: upper) if lower && upper
    return t(:range_min_only, lower: lower) if lower
    return t(:range_max_only, upper: upper) if upper
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
