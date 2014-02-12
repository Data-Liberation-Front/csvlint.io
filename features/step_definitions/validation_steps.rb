Then(/^I should see a page of validation results$/) do
  page.body.should include("Validation Results")
end

Then(/^I should see my URL$/) do
  page.body.should include(@url)
end

Then(/^my file should be persisted in the database$/) do
  Artefact.count.should == 1
  Artefact.first.filename.should == File.basename(@file)
end

Then(/^my url should be persisted in the database$/) do
  Artefact.count.should == 1
  Artefact.first.url.should == @url
  filename = File.basename(URI.parse(@url).path)
  Artefact.first.filename.should == filename
end

Then(/^the database record should have the type "(.*?)"$/) do |arg1|
  pending
end

Then(/^I should see my schema URL$/) do
  page.body.should include(@schema_url)
end