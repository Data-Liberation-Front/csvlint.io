require 'spec_helper'

describe "validation/index.html.erb" do
  
  it "should contain a URL entry box" do
    render
    rendered.should include "Enter CSV URL"
    rendered.should include %{<input id="url" name="url" type="text" />}
  end
  
end
