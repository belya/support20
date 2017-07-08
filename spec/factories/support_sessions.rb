FactoryGirl.define do
  factory :support_session do
    association :page
    jivo_id "someidinjivo"
  end
end
