class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by using a null session
  protect_from_forgery with: :null_session

  def standard_csv_options
    {row_sep: "\r\n", encoding: "UTF-8", force_quotes: true}
  end

  def index
    if params[:uri]
      validator = Validation.where(:url => params[:uri]).first
      render status: 404 and return if validator.nil?
      redirect_to validation_path(validator, format: params[:format]), status: 303
    end
  end

  def about
  end

end
