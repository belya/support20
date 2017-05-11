class Step < ApplicationRecord
  validates :type, presence: true

  def evaluate support_session, params
  end
end
