Given(/^it's two weeks in the future$/) do
  Timecop.freeze(2.weeks.from_now)
end

Given(/^it's three hours in the future$/) do
  Timecop.freeze(3.weeks.from_now)
end

Given(/^(\d+) hours have passed$/) do |hours|
  Timecop.freeze(hours.to_i.hours.from_now)
end
