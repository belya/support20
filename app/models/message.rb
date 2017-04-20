class Message < ApplicationRecord
  belongs_to :support_session
  validates :text, presence: true
end
