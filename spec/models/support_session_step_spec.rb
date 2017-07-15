require 'rails_helper'

RSpec.describe SupportSessionStep, type: :model do
  it "checks step" do
    should belong_to(:step)
  end

  it "checks support session" do
    should belong_to(:support_session)
  end

  it "checks values" do
    expect(subject.values).to eq({})
  end

  it "checks condition" do
    expect(subject.condition).to eq(nil)
  end
end
