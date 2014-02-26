class SchemasController < ApplicationController

  def index
    if params[:uri]
      schema = Schema.where(url: params[:uri]).first
      render status: 404 and return if schema.nil?
      redirect_to schema, status: 303
    else
      schemas = Schema.all
      @schemas = Kaminari.paginate_array(schemas).page(params[:page])
    end
  end
  
  def show
    @db_schema = Schema.where(id: params[:id]).first
    @schema = Csvlint::Schema.load_from_json_table(@db_schema.url)
    respond_to do |wants|
      wants.html
      wants.csv { send_data example_csv(@schema), type: "text/csv; charset=utf-8", disposition: "attachment" }
    end
  end

  private 
  
  def example_csv(schema)
    CSV.generate(standard_csv_options) do |csv|
      csv << schema.fields.map{|x| x.name }
    end
  end

end
