FactoryGirl.define do
  factory :coin_relation do
    association :coin_a
    association :coin_b
    step_min 0.1
    rate_act 10
    rate_ref 3
  end
end

