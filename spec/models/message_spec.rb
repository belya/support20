require 'rails_helper'

RSpec.describe Message, type: :model do
  it "checks support session" do
    should belong_to(:support_session)
  end

  it "checks session presence" do
    should validate_presence_of(:support_session).with_message(/must exist/)
  end

  it "checks text presence" do
    should validate_presence_of(:text)
  end
end
