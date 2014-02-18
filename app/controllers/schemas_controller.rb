class SchemasController < ApplicationController

  def index
    if params[:uri]
      redirect_to Schema.where(url: params[:uri]).first, status: 303
    else
      schemas = Schema.all
      @schemas = Kaminari.paginate_array(schemas).page(params[:page])
    end
  end
  
  def show
    db_schema = Schema.where(id: params[:id]).first
    @schema = Csvlint::Schema.load_from_json_table(db_schema.url)
  end

end
