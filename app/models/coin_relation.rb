# == Schema Information
#
# Table name: coin_relations
#
#  id         :integer          not null, primary key
#  coin_a_id  :integer
#  coin_b_id  :integer
#  step_min         :decimal(32, 8)   default(0.0), not null
#  rate_act         :decimal(32, 8)   default(0.0), not null
#  rate_ref         :decimal(32, 8)   default(0.0), not null
#  depth_fullupdate :date
#  depth_upper      :decimal(32, 8)   default(0.0), not null
#  depth_lower      :decimal(32, 8)   default(0.0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CoinRelation < ActiveRecord::Base
  belongs_to :coin_a, class_name: "Cointype"
  belongs_to :coin_b, class_name: "Cointype"
  has_many :depths
  has_many :autotrades

  # scope :coin_rel, -> (rel) { where("(coin_a_id = ? AND coin_b_id = ?)",rel.coin_a, rel.coin_b) }

  def self.t2cr(coin_t1, coin_t2)
    coin1 = Cointype.find_by(ticker: coin_t1)
    coin2 = Cointype.find_by(ticker: coin_t2)
    CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
  end

  def tickers_name
    "#{coin_a.ticker}-#{coin_b.ticker}" 
  end

  def lot_check?(value)
    (value >= lot_min) ? true : false 
  end

  def rate_check?(value)
    (value % step_min) == 0 ? true : false 
  end

  def represent_value(value)
    ((value / step_min).round(0)) * step_min
  end

  def represent_index(value)
    (value / step_min).round(0).to_i
  end

  def array(rate_start, rate_end, inc = true)
    # return arrey of rate which corersponds to allowed value with step_min
    # inc  ture: include edge, false: exclude edge

    n_start = represent_index( rate_start )
    n_end   = represent_index( rate_end )
    sign = (rate_start < rate_end) ? +1 : -1

    if inc then
      n = sign * ( n_end - n_start) + 1
      return Array.new( n ) { |idx| ( sign * idx + n_start) * self.step_min}
    else
      n = sign * ( n_end - n_start) - 1
      return nil if n < 0
      return Array.new( n ) { |idx| (sign * (idx + 1) + n_start) * self.step_min}
    end
  end
  
end

