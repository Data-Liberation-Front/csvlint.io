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

end
