# == Schema Information
#
# Table name: acnts
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  cointype_id :integer
#  balance     :decimal(32, 8)   default(0.0), not null
#  locked_bal  :decimal(32, 8)   default(0.0), not null
#  addr_in     :string(255)
#  addr_out    :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  acnt_num    :string(255)
#

FactoryGirl.define do
  factory :acnt do
    association :user
    association :cointype
    balance 100
    locked_bal 0
  end
end
