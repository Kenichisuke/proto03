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

class CoinRelation < ActiveRecord::Base
  belongs_to :coin_a, class_name: "Cointype"
  belongs_to :coin_b, class_name: "Cointype"


end
