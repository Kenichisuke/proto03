FactoryGirl.define do
  factory :cointype do
    # name "coins"

    # trait :cointype1 do
      name "Bitcoin"
      ticker "BTC"
      rank 100
      min_in 0
      fee_out 0.01
      fee_trd 0.001
    # end
    # trait :cointype2 do
    #   name "Litecoin"
    #   ticker "LTC"
    #   rank 80
    #   min_in 0
    #   fee_out 0.01
    #   fee_trd 0.001
    # end
    # trait :cointype3 do
    #   name "Monacoin"
    #   ticker "BTC"
    #   rank 60
    #   min_in 0
    #   fee_out 0.01
    #   fee_trd 0.001
    # end
    # trait :cointype4 do
    #   name "Dogecoin"
    #   ticker "DOGE"
    #   rank 40
    #   min_in 0
    #   fee_out 0.01
    #   fee_trd 0.001
    # end
  end

  factory :user do
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foofoobar"
    password_confirmation "foofoobar"
    factory :admin do
      admin true
    end
  end

  factory :acnt do
    user
    cointype
    balance 100
    locked_bal 0
  end
end