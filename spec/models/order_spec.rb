# == Schema Information
#
# Table name: orders
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  coin_a_id  :integer
#  coin_b_id  :integer
#  amt_a_org  :decimal(32, 8)   default(0.0), not null
#  amt_b_org  :decimal(32, 8)   default(0.0), not null
#  amt_a      :decimal(32, 8)   default(0.0), not null
#  amt_b      :decimal(32, 8)   default(0.0), not null
#  rate       :decimal(32, 10)  default(0.0), not null
#  buysell    :boolean
#  flag       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Order, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
