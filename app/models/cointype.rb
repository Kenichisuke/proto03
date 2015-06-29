class Cointype < ActiveRecord::Base
  has_many :order, foreign_key: "coin_a_id"
  has_many :order, foreign_key: "coin_b_id"
  has_many :acnt
  has_many :coinio  

  validates :name, presence: true, uniqueness: true
  validates :ticker, presence: true, uniqueness: true
  validates :rank, presence: true, uniqueness: true
  validates :min_in, numericality: {greater_than_or_equal_to: 0.0}
  validates :fee_out, numericality: {greater_than_or_equal_to: 0.0}
  validates :fee_trd, numericality: {greater_than_or_equal_to: 0.0} 

  def self.tickers
    ret = []
    coins = Cointype.all
    coins.each do | co |
      ret << co.ticker
    end
    return ret
  end

end
