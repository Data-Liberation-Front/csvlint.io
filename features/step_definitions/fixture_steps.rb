Given(/^the fixture "(.*?)" is available at the URL "(.*?)"$/) do |filename, url|
  body = File.read(File.join(Rails.root, 'fixtures', filename))
  stub_request(:get, url).to_return(body: body, headers: {"Content-Type" => "text/csv; charset=utf-8; header=present"})  
  stub_request(:head, url).to_return(:status => 200)
end

Given(/^there are (\d+) validations in the database$/) do |num|
  num.to_i.times do |n|
    url = "http://example.org/test#{n}.csv"
    body = File.read(File.join(Rails.root, 'fixtures', 'csvs/valid.csv'))
    stub_request(:get, url).to_return(body: body, headers: {"Content-Type" => "text/plain"})
    stub_request(:head, url).to_return(:status => 200)
    steps %{
      When I go to the homepage
      And I enter "#{url}" in the "url" field
      And I press "Validate"
    }
  end
end

Given(/^there are (\d+) schemas in the database$/) do |num|
  num.to_i.times do |n|
    FactoryGirl.create :schema
  end
end

Given(/^I have updated the URL "(.*?)"$/) do |url|
  stub_request(:head, url).to_return(:status => 200)
end

Given(/^the CSV has not changed$/) do
  stub_request(:head, @url).to_return(:status => 304)
end

Given(/^the server does not support If\-Modified\-Since$/) do
  stub_request(:head, @url).to_return(:status => 200)
end

Given(/^the URL "(.*?)" returns a status of "(.*?)"$/) do |url, status|
  stub_request(:any, url).to_return(:status => status)
end

Given(/^"(.*?)" has been previously used for validation$/) do |url|
  FactoryGirl.create :schema, url: url
end

Given(/^the data exceeds the amount the proxy can handle/) do
  # step implementation to get Cucumber and Capybara to catch the HTTP errors that are thrown by the dev environment
  #stub_request(:post, 'localhost/package.json').
  #    to_return(:status => 413)

  # allow(PackageController).to receive(:create).and_return("I actually know nothing of worth") #works
  allow_any_instance_of(PackageController).to receive(:create).and_raise(ArgumentError)
  # allow(Package).to receive(:nginx).and_return( render :nothing => true, :status => 413) # breaks with undefined method `render'
  # allow(Package).to receive(:nginx) { render :nothing => true, :status => 413 } # still breaks with undefined method render
  # byebug

end