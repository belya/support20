require 'rails_helper'

RSpec.describe Step, type: :model do
  subject do
    create :alert_step
  end

  let :support_session do
    create :support_session
  end

  before do
    support_session.steps.push create(:alert_step)
    support_session.steps.push subject
    support_session.steps.push subject
  end

  it "checks type presence" do
    should validate_presence_of(:type)
  end

  it "checks dataset id" do
    subject.update(dataset_id: 42)
    expect(subject.dataset_id).to eq(42)
  end

  it "checks default dataset id" do
    create :alert_step, dataset_id: nil
    expect(Step.last.dataset_id).not_to be_nil
  end

  it "checks differend dataset ids" do
    create :alert_step, dataset_id: nil
    create :alert_step, dataset_id: nil
    expect(Step.first.dataset_id).not_to eq(Step.last.dataset_id)
  end

  it "checks evaluate method" do
    subject.evaluate({}, {})
  end

  it "checks support session step" do
    expect(subject.step(support_session)).to eq support_session.support_session_steps.last
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

  before do
    support_session.steps.push subject
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

  it "checks value" do
    subject.evaluate(support_session, ActionController::Parameters.new(value: "value"))
    expect(support_session.support_session_steps.first.values[subject.value_name]).to eq("value")
  end

  it "checks condition" do
    subject.evaluate(support_session, ActionController::Parameters.new(value: "value"))
    expect(support_session.support_session_steps.first.condition).to be_truthy
  end

  it "checks condition with empty value" do
    subject.evaluate(support_session, ActionController::Parameters.new(value: nil))
    expect(support_session.support_session_steps.first.condition).to be_falsey
  end
end

RSpec.describe FinishStep, type: :model do
  let :support_session do
    create :support_session
  end

  it "checks type" do
    expect(subject.type).to eq("FinishStep")
  end
end

RSpec.describe ServerStep, type: :model do
  subject do
    create :server_step, 
      action: "step(support_session).update(values: {email: 'someemail@mail.com'})"
  end

  let :support_session do
    create :support_session
  end

  before do
    support_session.steps.push subject
  end

  it "checks description presence" do
    should validate_presence_of(:description)
  end

  it "checks type" do
    expect(subject.type).to eq("ServerStep")
  end

  it "checks action method" do
    subject.evaluate(support_session, {})    
    expect(support_session.support_session_steps.first.values[:email]).to eq("someemail@mail.com")
  end

  it "checks action name presence" do
    should validate_presence_of(:action_name)
  end
end