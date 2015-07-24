Given(/^it's two weeks in the future$/) do
  Timecop.freeze(2.weeks.from_now)
end

Given(/^it's three hours in the future$/) do
  Timecop.freeze(3.weeks.from_now)
end

Given(/^(\d+) hours have passed$/) do |hours|
  # byebug
  Timecop.freeze(hours.to_i.hours.from_now)
  # TimeCop only sets and spoofs the ruby clock - when the app starts both ruby and mongo have the system time available
  # to them - this time is only altered from POV of ruby code :. the Mongo 'created_at' fields will stay in real time
end
