require 'uri'

class ValidationController < ApplicationController

  def index
  end

  def redirect
    redirect_to validate_path(url: params["url"])
  end

  def validate
    # Check we have a URL
    @url = params[:url]
    redirect_to root_path and return if @url.nil?
    # Check it's valid
    @url = begin
      URI.parse(@url)
    rescue URI::InvalidURIError
      redirect_to root_path and return
    end
    # Check scheme
    redirect_to root_path and return unless ['http', 'https'].include?(@url.scheme)
  end

end
