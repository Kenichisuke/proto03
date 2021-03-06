# == Schema Information
#
# Table name: coin_relations
#
#  id         :integer          not null, primary key
#  coin_a_id  :integer
#  coin_b_id  :integer
#  step_min   :decimal(32, 8)   default(0.0), not null
#  rate_act   :decimal(32, 8)   default(0.0), not null
#  rate_ref   :decimal(32, 8)   default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :coin_relation do
    association :coin_a
    association :coin_b
    step_min 10
    rate_act 5000
    rate_ref 4990
    book_trig 30
    book_range 60
  end
end

