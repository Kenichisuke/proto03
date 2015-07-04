# == Schema Information
#
# Table name: trades
#
#  id         :integer          not null, primary key
#  order_id   :integer
#  amt_a      :decimal(32, 8)   default(0.0), not null
#  amt_b      :decimal(32, 8)   default(0.0), not null
#  fee        :decimal(32, 8)   default(0.0), not null
#  flag       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  coin_a_id  :integer
#  coin_b_id  :integer
#

require 'rails_helper'

RSpec.describe Trade, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
