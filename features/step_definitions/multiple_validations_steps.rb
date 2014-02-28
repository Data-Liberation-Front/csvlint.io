When(/^I enter the following urls:$/) do |table|
  count = 0
  
  urls = table.raw.map { |url| url.first }
    
  urls.each do |url|
    fill_in "url_#{count}", with: url
    page.find(".btn-clone").click
    count += 1
  end
end

Then(/^the package validations should have the correct schema$/) do
  package = Package.first
  package.validations.each do |validation|
    result = Marshal.load validation.result
    result.schema.fields[0].name.should == "FirstName"
    result.schema.fields[1].name.should == "LastName"
    result.schema.fields[2].name.should == "Insult"
  end
end