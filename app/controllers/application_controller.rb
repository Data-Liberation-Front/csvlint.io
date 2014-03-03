class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def standard_csv_options
    {row_sep: "\r\n", encoding: "UTF-8", force_quotes: true}
  end

end
