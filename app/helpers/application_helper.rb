module ApplicationHelper
  def step_type step
    step.type.underscore.gsub("_step", "")
  end
end
