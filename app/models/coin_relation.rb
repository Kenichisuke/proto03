class CoinRelation < ActiveRecord::Base
  belongs_to :coin_a, class_name: "Cointype"
  belongs_to :coin_b, class_name: "Cointype"


end
