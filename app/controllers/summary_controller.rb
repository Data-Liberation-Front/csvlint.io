class SummaryController < ApplicationController
  
  before_filter(:only => [:index]) { alternate_formats [:json] }
    
  def index
    @summary = Summary.last
  end
  
end