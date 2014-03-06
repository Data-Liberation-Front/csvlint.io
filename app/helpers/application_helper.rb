module ApplicationHelper

  def get_menu(name)
    if eval("$#{name}").nil?
      eval("$#{name} = #{YAML.load_file("#{Rails.root.to_s}/config/menus/#{name}.yml")}")
    end
    return eval("$#{name}")
  end

  
  def i18n_set?(key)
    I18n.t key, :raise => true rescue false
  end
  
end
