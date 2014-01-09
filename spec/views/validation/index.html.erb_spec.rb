require 'spec_helper'

describe "validation/index.html.erb" do
  
  it "should contain a URL entry box" do
    render
    rendered.should include %{<input class="form-control" id="url" name="url" placeholder="Enter CSV URL" type="url" value="" />}
  end
  
end
