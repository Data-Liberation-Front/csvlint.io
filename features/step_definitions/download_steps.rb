When(/^that CSV file should have a field "(.*?)"$/) do |content|
  page.body.should include content
end

When(/^that CSV file should use CRLF line endings$/) do
  page.body.should include "\r\n"
end

When(/^that CSV file should have double-quoted fields$/) do
  page.body.should_not match /[^\"],[^\"]/
end

Then(/^a CSV file should be downloaded$/) do
  headers = page.response_headers
  headers["Content-Type"].should == "text/csv; charset=utf-8"
  headers["Content-Disposition"].should == "attachment"
end