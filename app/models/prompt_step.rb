class PromptStep < Step
  validates :value_name, :value_type, presence: true

  def evaluate(support_session, params)
    step(support_session).update(
      values: {value_name => params[:value]},
      condition: params[:value].present?
    )
  end
end