module StepsHelper
  def step_types 
    {}.tap do |hash|
      [AlertStep, PromptStep, ServerStep].each do |step|
        hash[step.model_name.human] = step.name
      end
    end
  end
end
