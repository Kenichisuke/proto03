# == Schema Information
#
# Table name: cointypes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  ticker     :string(255)
#  rank       :integer
#  min_in     :float(24)
#  fee_out    :float(24)
#  fee_trd    :float(24)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  init_amt   :decimal(32, 10)  default(0.0), not null
#  daemon     :string(255)
#

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
