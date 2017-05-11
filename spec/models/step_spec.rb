require 'rails_helper'

RSpec.describe Step, type: :model do
  it "checks type presence" do
    should validate_presence_of(:type)
  end

  it "checks evaluate method" do
    subject.evaluate({}, {})
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
  subject do
    create :prompt_step
  end

  let :support_session do
    create :support_session
  end

  it "checks type" do
    expect(subject.type).to eq("PromptStep")
  end

  it "checks value name presence" do
    should validate_presence_of(:value_name)
  end

  it "checks value type presence" do
    should validate_presence_of(:value_type)
  end

  it "checks evaluate" do
    subject.evaluate(support_session, ActionController::Parameters.new(value: "value"))
    expect(support_session.values[subject.value_name]).to eq("value")
  end
end

RSpec.describe FinishStep, type: :model do
  it "checks type" do
    expect(subject.type).to eq("FinishStep")
  end
end

RSpec.describe ServerStep, type: :model do
  let :support_session do
    create :support_session
  end

  it "checks type" do
    expect(subject.type).to eq("ServerStep")
  end

  it "checks action presence" do
    should validate_presence_of(:action)
  end

  it "checks action method" do
    subject.update(action: "support_session.update(values: {email: 'someemail@mail.com'})")
    subject.evaluate(support_session, {})    
    expect(support_session.values[:email]).to eq("someemail@mail.com")
  end

  it "checks action name presence" do
    should validate_presence_of(:action_name)
  end
end