# == Schema Information
#
# Table name: price_hists
#
#  id         :integer          not null, primary key
#  dattim     :datetime
#  st         :float(24)
#  mx         :float(24)
#  mn         :float(24)
#  en         :float(24)
#  vl         :float(24)
#  ty         :integer
#  coin_a_id  :integer
#  coin_b_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PriceHist < ActiveRecord::Base
  belongs_to :coin_a, class_name: "Cointype"
  belongs_to :coin_b, class_name: "Cointype"

  enum ty: [ :min_5, :min_15, :hr_1, :hr_8, :dy_1 ]

  scope :coins, -> (coin1, coin2) { where("(coin_a_id = ? AND coin_b_id = ?)", coin1, coin2) }
end

# :min_5:   -> 4hr 
# :min_15:  -> 12hr
# :hr_1:    -> 48hr (2days)
# :hr_8:    -> 16days
# :dy_1:    -> 48days
