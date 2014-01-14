module ApplicationHelper
  
  def i18n_set?(key)
    I18n.t key, :raise => true rescue false
  end
  
end
