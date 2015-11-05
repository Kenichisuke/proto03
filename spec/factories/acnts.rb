FactoryGirl.define do
  factory :acnt do
    association :user
    association :cointype
    balance 100
    locked_bal 0
  end
end