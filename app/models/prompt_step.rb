class PromptStep < Step
  validates :value, :value_type, presence: true
end