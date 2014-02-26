class PackageController < ApplicationController
  
  def show
    @package = Package.find( params[:id] )
    @dataset = Marshal.load(@package.dataset)
    @validations = Kaminari.paginate_array(@package.validations).page(params[:page])  
  end
end
