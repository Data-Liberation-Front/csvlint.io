Given(/^the fixture "(.*?)" is available at the URL "(.*?)"$/) do |filename, url|
  body = File.read(File.join(Rails.root, 'fixtures', filename))
  stub_request(:get, url).to_return(body: body, headers: {"Content-Type" => "text/plain"})  
end

Given(/^there are (\d+) validations in the database$/) do |num|
  num.to_i.times do |n|
    url = "http://example.org/test#{n}.csv"
    body = File.read(File.join(Rails.root, 'fixtures', 'csvs/valid.csv'))
    stub_request(:get, url).to_return(body: body, headers: {"Content-Type" => "text/plain"})
    steps %{
      When I go to the homepage
      And I enter "#{url}" in the "url" field
      And I press "Validate"
    }
  end
end

Given(/^I have updated the URL "(.*?)"$/) do |url|
  body = File.read(File.join(Rails.root, 'fixtures', "csvs/valid.csv"))
  stub_request(:get, url).to_return(body: body, headers: {"Content-Type" => "text/plain", "Last-Modified" => DateTime.now.rfc2822})
end

Given(/^the CSV has not changed$/) do
  stub_request(:get, @url).to_return(:status => 304)
end
