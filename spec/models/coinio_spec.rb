# == Schema Information
#
# Table name: coinios
#
#  id          :integer          not null, primary key
#  cointype_id :integer          default(1), not null
#  tx_category :integer
#  amt         :decimal(32, 8)   default(0.0), not null
#  flag        :integer
#  txid        :string(255)      not null
#  addr        :string(255)
#  acnt_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  fee         :decimal(32, 16)  default(0.0)
#

require 'rails_helper'

RSpec.describe Coinio, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
