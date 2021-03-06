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

class Cointype < ActiveRecord::Base
  has_many :orders, foreign_key: "coin_a_id"
  has_many :orders, foreign_key: "coin_b_id"
  has_many :acnts
  has_many :coinios  
  has_many :coin_relations, foreign_key: "coin_a_id"
  has_many :coin_relations, foreign_key: "coin_b_id"

  validates :name, presence: true, uniqueness: true
  validates :ticker, presence: true, uniqueness: true
  validates :rank, presence: true, uniqueness: true
  validates :min_in, numericality: {greater_than_or_equal_to: 0.0}
  validates :fee_out, numericality: {greater_than_or_equal_to: 0.0}
  validates :fee_trd, numericality: {greater_than_or_equal_to: 0.0} 

  def self.tickers
    ret = []
    coins = Cointype.all.order('rank DESC')
    coins.each do | co |
      ret << co.ticker
    end
    return ret
  end

  def self.tickercomb
    ticks = tickers
    ret = []
    n = ticks.count - 1
    for i in 0...n
      for j in (i + 1)..n
        ret << [ticks[i], ticks[j]]
      end
    end
    return ret
  end
  
end
