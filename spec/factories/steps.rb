FactoryGirl.define do
  factory :step do
  end

  factory :alert_step, class: AlertStep, parent: :step do
    text "Some text"
  end

  factory :prompt_step, class: PromptStep, parent: :step do
    value "Some value"
    value_type "String"
  end

  factory :server_step, class: ServerStep, parent: :step do
    action "Kill 'em all"
  end

  factory :finish_step, class: FinishStep, parent: :step
end
