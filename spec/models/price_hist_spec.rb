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

require 'rails_helper'

RSpec.describe PriceHist, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
