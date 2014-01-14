require 'spec_helper'

describe "validation/_message.html.erb" do

  it "displays errors and warnings correctly" do
    
    {
      :encoding => "Your CSV appears to be encoded in <code>iso-8859-1</code>. We recommend you use <code>UTF-8</code>.",
      :no_encoding => "The URL your CSV is referenced at appears to not be sending an encoding header with its content-type.",
      :invalid_encoding => "Your CSV appears to be encoded in <code>iso-8859-1</code>, but invalid characters were found. This can often be caused by copying and pasting data from a different source.",
      :wrong_content_type => "The URL your CSV is referenced at appears to be sending the wrong content-type header. We recommend that you configure your server to send the <code>text/csv</code> content-type header",
      :no_content_type => "The URL your CSV is referenced at does not appear to be sending a content-type header. We recommend that you configure your server to send the <code>text/csv</code> content-type header"
    }.each do |k, v|
      
      message = Csvlint::ErrorMessage.new(:type => k)
      validator = double("validator")
      validator.stub(:encoding) { "iso-8859-1" }
      
      validator 
      render :partial => "validation/message", :locals => { :message => message, :validator => validator }
      
      rendered.should include v
    end
    
  end

end
