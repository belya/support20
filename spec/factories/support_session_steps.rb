FactoryGirl.define do
  factory :support_session_step do
    association :step, factory: :alert_step
    association :support_session
  end
end
