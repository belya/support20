FactoryGirl.define do
  factory :support_session_step do
    association :step
    association :support_session
  end
end
