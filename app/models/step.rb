class Step < ApplicationRecord
  include AttachedToDataset
  
  validates :type, presence: true

  def evaluate support_session, params
  end

  def step support_session
    SupportSessionStep.where(step: self, support_session: support_session).last
  end
end
