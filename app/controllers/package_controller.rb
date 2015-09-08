class PackageController < ApplicationController
  before_filter :preprocess, :only => :create

  # preprocess performs necessary formatting of appended or hyperlinked files on the CSVlint frontend

  before_filter(:only => [:show]) { alternate_formats [:json] }

  def create
    @package = Package.create
    if params[:format] == "json"
      @package.delay.process(params)
    else
      @package.process(params)

      if @package.validations.count == 1
        redirect_to validation_path(@package.validations.first)
      else
        redirect_to package_path(@package)
      end
    end
  end

  def show
    @package = Package.find( params[:id] )

    if @package.validations.count == 1 && params[:format] != "json"
      redirect_to validation_path(@package.validations.first)
    end

    @dataset = Marshal.load(@package.dataset) rescue nil
    @validations = @package.validations
  end

  private

    def preprocess
      remove_blanks!
      redirect_to root_path and return unless urls_valid? || files_present?
    end

    def urls_valid?
      return false if params[:urls].blank?
      params[:urls].each do |url|
        return false if url.blank?
        # Check it's valid
        begin
          url = URI.parse(url)
          return false unless ['http', 'https'].include?(url.scheme)
        rescue URI::InvalidURIError
          return false
        end
      end
      return true
    end

    def remove_blanks!
      params[:urls].reject! { |url| url.blank? } unless params[:urls].blank?
      params[:files].reject! { |data| data.blank? } unless params[:files].blank?
    end
    def files_present?
      params[:files].presence || params[:files_data].presence || params[:file_ids].presence
    end

end
