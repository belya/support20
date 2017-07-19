require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the StepsHelper. For example:
#
# describe StepsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ApplicationHelper, type: :helper do
  it "checks step type" do
    expect(step_type(create(:alert_step))).to eq("alert")
  end
end
