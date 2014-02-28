When(/^I enter the following urls:$/) do |table|
  count = 0
  
  urls = table.raw.map { |url| url.first }
    
  urls.each do |url|
    fill_in "url_#{count}", with: url
    page.find(".btn-clone").click
    count += 1
  end
end