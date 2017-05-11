class SupportSession < ApplicationRecord
  include AASM
  has_many :messages
  has_many :support_session_steps
  has_many :steps, through: :support_session_steps
  belongs_to :page
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

  def values
    support_session_steps.reduce({}) do |hash, step|
      hash.merge(step.values)
    end
  end

  def last_step
    if steps.empty?
      Step.new
    else
      steps.last 
    end
  end
end
