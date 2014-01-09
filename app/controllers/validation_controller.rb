class ValidationController < ApplicationController

  def index
  end

  def redirect
    redirect_to validate_path(url: params["url"])
  end

  def validate
    @url = params[:url]
  end

end
