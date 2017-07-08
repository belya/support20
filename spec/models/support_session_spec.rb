require 'rails_helper'

RSpec.describe SupportSession, type: :model do
  subject do
    create :support_session, steps: [create(:alert_step), create(:alert_step)]
  end

  it "checks status" do
    should define_enum_for(:status).with([:created, :completed, :waiting, :attached, :manual_completed])
  end

  it "checks default status" do
    expect(subject.status).to eq("created")
  end

  it "checks messages" do
    should have_many(:messages)
  end

  it "checks jivo id presence" do
    should validate_presence_of(:jivo_id)
  end

  it "checks page" do
    should belong_to(:page)
  end

  it "checks steps" do
    should have_many(:steps).through(:support_session_steps)
  end

  it "checks support session steps" do
    should have_many(:support_session_steps)
  end

  it "checks last step" do
    expect(subject.last_step).to eq(AlertStep.last)
  end

  it "checks empty last step" do
    subject.steps.clear
    expect(subject.last_step.class).to eq(Step)
  end

  it "checks values" do
    subject.support_session_steps.first.update(values: {"first" => "value"})
    subject.support_session_steps.second.update(values: {"second" => "value"})
    expect(subject.values).to eq({"first" => "value", "second" => "value"})
  end

  context "statuses" do
    context "await event" do
      it "checks from created" do
        subject.await!
        expect(subject.waiting?).to be_truthy
      end

      it "checks from another status" do
        subject.waiting!
        expect {
          subject.await!
        }.not_to change{subject.status}
      end
    end

    context "attach event" do
      it "checks from waiting" do
        subject.waiting!
        subject.attach!
        expect(subject.attached?).to be_truthy
      end

      it "checks from another status" do
        subject.attached!
        expect {
          subject.attach!
        }.not_to change{subject.status}
      end
    end

    context "finish event" do
      it "checks from attached" do
        subject.attached!
        subject.finish!
        expect(subject.manual_completed?).to be_truthy
      end

      it "checks from created" do
        subject.finish!
        expect(subject.completed?).to be_truthy
      end

      it "checks from another status" do
        subject.completed!
        expect {
          subject.finish!
        }.not_to change{subject.status}
      end
    end
  end
end
