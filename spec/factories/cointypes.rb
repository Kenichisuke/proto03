FactoryGirl.define do
  factory :cointype do

    factory :bitcoin, class: Cointype do
      name "Bitcoin"
      ticker "BTC"
      rank 100
      min_in 0
      fee_out 0.01
      fee_trd 0.001
      init_amt 0
    end

    factory :litecoin, class: Cointype do
      name "Litecoin"
      ticker "LTC"
      rank 80
      min_in 0
      fee_out 0.01
      fee_trd 0.001
      init_amt 0      
    end

    factory :monacoin, class: Cointype do
      name "Monacoin"
      ticker "MONA"
      rank 60
      min_in 0
      fee_out 0.01
      fee_trd 0.001
    end

    factory :dogecoin, class: Cointype do
      name "Dogecoin"
      ticker "DOGE"
      rank 40
      min_in 0
      fee_out 0.01
      fee_trd 0.001
    end
  end
end