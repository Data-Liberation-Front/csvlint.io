require 'uri'
require 'zipfile'

class ValidationController < ApplicationController

  before_filter(:only => [:index, :show]) { alternate_formats [:json] }

  def index
    @validations = Validation.where(:url.ne => nil)
                   .order_by(:created_at.desc)
                   .page(params[:page]).per(7)
  end

  def show
    @validation = Validation.fetch_validation(params[:id], params[:format], params[:revalidate])
    # byebug - this was used to see what the instance validation had in comparison to the find-by-id validation
    raise ActionController::RoutingError.new('Not Found') if @validation.state.nil?
    # @result stores all the validation errors, warnings and information messages
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
    # byebug - this byebug was used to compare the above find-by-validation with the show's instance validation
    # v when retrieved after one update validation loses it's csv_id as is set to nil as it isn't finding the same Validation
    v.update_validation(dialect)
    redirect_to validation_path(v)

  end

  private

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
      }.reject {|k,v| v.nil?}
    end

end
