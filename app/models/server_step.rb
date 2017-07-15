class ServerStep < Step
  validates :action, :action_name, :description, presence: true  

  def evaluate(support_session, params)
    eval action
  end
end