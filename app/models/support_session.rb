class SupportSession < ApplicationRecord
  include AASM
  has_many :messages
  serialize :step_ids, Array
  serialize :values, Hash
  enum status: [:created, :completed, :waiting, :attached, :manual_completed]
  aasm column: :status, enum: true, whiny_transitions: false do
    state :created, :initial => true
    state :completed, :waiting, :attached, :manual_completed

    event :await do
      transitions from: :created, to: :waiting
    end

    event :attach do
      transitions from: :waiting, to: :attached
    end

    event :finish do
      transitions from: :attached, to: :manual_completed
      transitions from: :created, to: :completed
    end
  end

  def last_step
    if step_ids.empty?
      Step.new
    else
      Step.find(step_ids.last) 
    end
  end
end
