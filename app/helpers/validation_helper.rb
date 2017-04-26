# Monkey patch line_breaks method to handle older Validator objects that store @line_breaks as strings

module Csvlint
  class Validator
    def line_breaks
      @line_breaks = [@line_breaks].flatten
      if @line_breaks.uniq.count > 1
        :mixed
      else
        @line_breaks.uniq.first
      end
    end
  end
end

module ValidationHelper

  def error_and_warning_count(errors, warnings, options)
    # Generate string
    components = []
    components << pluralize(errors.count, t(:error).titleize) unless errors.empty?
    components << pluralize(warnings.count, t(:warning).titleize) unless warnings.empty?
    # Do nothing if nothing to print
    return '' if components.empty?
    # Wrap it up
    wrapper = options[:wrapper] || :span
    content_tag(wrapper, components.join(', '))
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
        :min_length       => constraint(message, validator, "minLength"),
        :max_length       => constraint(message, validator, 'maxLength'),
        :min_value        => constraint(message, validator, 'minimum'),
        :max_value        => constraint(message, validator, 'maximum'),
        :pattern          => constraint(message, validator, 'pattern'),
        :expected_headers => header_validate(message),
        :header           => schema_field(message, validator).try(:name),
        :value            => message.content,
    }

    if validator.headers
      validator.headers.each do |k,v|
        key = "header_#{k.gsub("-", "_")}".to_sym
        variables[key.downcase] = v
      end
    end

    variables

  end

  def header_validate(message)
    if message.constraints.present?
      expected_header_values = message.constraints["expectedHeader"].present? ? message.constraints["expectedHeader"] : false
    end
    expected_header_values
  end

  def extra_guidance(validator, validation, message)
    extra = []
    extra << :old_content_type if message.type == :wrong_content_type && validator.content_type == "text/comma-separated-values"
    extra << :s3_upload if message.type == :wrong_content_type && validator.headers["Server"] == "AmazonS3"
    extra << :github if message.type == :wrong_content_type && validation.url.to_s.match(/raw.githubusercontent.com/)
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

  def schema_field(message, validator)
    validator.schema.fields[message.column-1] rescue nil
  end

  def constraint(message, validator, name)
    schema_field(message, validator).try(:constraints).try(:[], name)
  end

  def category_count(message, category)
    message.select{ |m| m.category == category }.count
  end

  def category_class(result, type, category)
    category_count(result.send(type), category) > 0 ? type : "active #{type}-none"
  end

end
