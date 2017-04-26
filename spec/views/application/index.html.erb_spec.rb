require 'spec_helper'

describe "application/index.html.erb", type: :view do
  
  it "should contain a URL entry box" do
    render
    expect(rendered).to include %{<input type="url" name="urls[]" id="url_0" value="" class="form-control" placeholder="Enter URL" />}
  end
  
end
