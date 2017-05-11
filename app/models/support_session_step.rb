class SupportSessionStep < ApplicationRecord
  belongs_to :step
  belongs_to :support_session
  serialize :values, Hash
end
