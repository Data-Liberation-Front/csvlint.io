class SchemasController < ApplicationController

  def index
    schemas = Schema.all
    @schemas = Kaminari.paginate_array(schemas).page(params[:page])
  end

end
