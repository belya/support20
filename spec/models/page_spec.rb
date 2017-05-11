require 'rails_helper'

RSpec.describe Page, type: :model do
  subject do
    create :page
  end

  it "checks link presence" do
    should validate_presence_of(:link)
  end

  it "checks dataset id" do
    subject.update(dataset_id: 42)
    expect(subject.dataset_id).to eq(42)
  end

  it "checks default dataset id" do
    subject.update(dataset_id: nil)
    expect(subject.dataset_id).to eq(subject.id.to_i)
  end
end
