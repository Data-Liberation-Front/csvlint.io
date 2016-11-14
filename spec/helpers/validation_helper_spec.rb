require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ValidationHelper. For example:
#
# describe ValidationHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end

describe ValidationHelper, type: :helper do

  it "should count the correct messages by category" do

    [:structure, :schema, :context].each do |category|
      messages = []

      num = rand(1..40)

      num.times { messages << Csvlint::ErrorMessage.new(nil, category, nil, nil, nil, nil) }

      expect(category_count(messages, category)).to eq(num)
    end

  end

end
