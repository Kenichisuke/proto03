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

require 'rails_helper'

RSpec.describe Cointype, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
