FactoryGirl.define do
  factory :order do
  	association :user
    association :coin_a
    association :coin_b
    amt_a 1.0
    amt_b 10.0
    rate 10.0
    amt_a_org 1.0
    amt_b_org 10.0
    buysell true
    flag 0
  end
end

