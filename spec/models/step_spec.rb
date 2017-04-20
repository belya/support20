require 'rails_helper'

RSpec.describe Step, type: :model do
  it "checks type presence" do
    should validate_presence_of(:type)
  end
end

RSpec.describe AlertStep, type: :model do
  it "checks type" do
    expect(subject.type).to eq("AlertStep")
  end

  it "checks text presence" do
    should validate_presence_of(:text)
  end
end

RSpec.describe PromptStep, type: :model do
  it "checks type" do
    expect(subject.type).to eq("PromptStep")
  end

  it "checks value name presence" do
    should validate_presence_of(:value)
  end

  it "checks value type presence" do
    should validate_presence_of(:value_type)
  end
end

RSpec.describe FinishStep, type: :model do
  it "checks type" do
    expect(subject.type).to eq("FinishStep")
  end
end

RSpec.describe ServerStep, type: :model do
  it "checks type" do
    expect(subject.type).to eq("ServerStep")
  end

  it "checks action presence" do
    should validate_presence_of(:action)
  end
end

RSpec.describe SupportStep, type: :model do
  it "checks type" do
    expect(subject.type).to eq("SupportStep")
  end
end