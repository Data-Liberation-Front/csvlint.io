require 'spec_helper'

describe "application/index.html.erb" do
  
  it "should contain a URL entry box" do
    render
    rendered.should include %{<input class="form-control" id="url_0" name="urls[]" placeholder="Enter URL" type="url" value="" />}
  end
  
end
