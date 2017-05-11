class PromptStep < Step
  validates :value_name, :value_type, presence: true

  def evaluate(support_session, params)
    support_session.values[value_name] = params[:value]
    support_session.save
  end
end