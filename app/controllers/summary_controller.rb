class SummaryController < ApplicationController

  before_filter(:only => [:index]) { alternate_formats [:json] }

  def index
    @summary = Legacy::Summary.last
  end

end
