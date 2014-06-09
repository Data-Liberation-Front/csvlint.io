require 'uri'
require 'zipfile'

class ValidationController < ApplicationController

  before_filter(:only => [:index, :show]) { alternate_formats [:json] }

  def index
    validations = Validation.where(:url.ne => nil).sort_by{ |v| v.created_at }.reverse!
    validations.uniq!{ |v| v.url }
    @validations = Kaminari.paginate_array(validations).page(params[:page]).per(7)
  end

  def show
    @validation = Validation.fetch_validation(params[:id], params[:format], params[:revalidate])

    raise ActionController::RoutingError.new('Not Found') if @validation.state.nil?

    @result = @validation.validator
    @dialect = @result.dialect || Validation.standard_dialect
    # Responses
    respond_to do |wants|
      wants.html
      wants.json
      wants.png { render_badge(@validation.state, "png") }
      wants.svg { render_badge(@validation.state, "svg") }
      wants.csv { send_data standardised_csv(@validation), type: "text/csv; charset=utf-8", disposition: "attachment" }
    end
  end

  def update
    dialect = build_dialect(params)
    v = Validation.find(params[:id])
    v.update_validation(dialect)
    redirect_to validation_path(v)
  end

  private

    def render_badge(state, format)
      send_file File.join(Rails.root, 'app', 'views', 'validation', "#{state}.#{format}"), disposition: 'inline'
    end

    def standardised_csv(validation)
      data = Marshal.load(validation.result).data
      CSV.generate(standard_csv_options) do |csv|
        data.each do |row|
          csv << row if row
        end
      end
    end

    def build_dialect(params)
      case params[:line_terminator]
      when "auto"
        line_terminator = :auto
      when "\\n"
        line_terminator = "\n"
      when "\\r\\n"
        line_terminator = "\r\n"
      end

      {
        "header" => params[:header],
        "delimiter" => params[:delimiter],
        "skipInitialSpace" => params[:skip_initial_space],
        "lineTerminator" => line_terminator,
        "quoteChar" => params[:quote_char]
      }
    end

end
