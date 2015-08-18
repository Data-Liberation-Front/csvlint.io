class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by using a null session
  protect_from_forgery with: :null_session

  def standard_csv_options
    {row_sep: "\r\n", encoding: "UTF-8", force_quotes: true}
  end

  def index
    if params[:uri]
      validator = Validation.where(:url => params[:uri]).first
      if validator.nil?
        Validation.delay.create_validation(params[:uri])
        respond_to do |wants|
          wants.html { render status: 202 }
          wants.json { render status: 202 }
          wants.png { render_badge("pending", "png", 202) }
          wants.svg { render_badge("pending", "svg", 202) }
        end
      else
        redirect_to validation_path(validator, format: params[:format]), status: 303
      end
    end
  end

  def about
  end

  def privacy
  end

  private

    def render_badge(state, format, status = 200)
      send_file File.join(Rails.root, 'app', 'views', 'validation', "#{state}.#{format}"), disposition: 'inline', status: status
    end

end
