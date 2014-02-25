Then(/^the url "(.*?)" should be persisted in the database$/) do |url|
  Validation.count.should == 1
  Validation.first.url.should == url
  filename = File.basename(URI.parse(url).path)
  Validation.first.filename.should == filename
end