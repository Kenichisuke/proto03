class OpenOrder

  include ActiveModel::Model  #form_for を使うのに必要

  attr_accessor :user_id, :coin_relation_id, :rate, :steprate, :num, :amt, :updown

  def initialize(user_id: nil, coin_relation_id: nil, rate: 100, steprate: 10, num: 1, amt: 1, updown: 0)
    @user_id = user_id.to_i
    @coin_relation_id = coin_relation_id.to_i
    @rate = rate.to_d
    @steprate = steprate.to_f
    @num = num.to_i
    @amt = amt.to_f
    @updown = updown.to_i  # both: 0, up(sell): 1, down(buy):2
  end
  # FIXME: @user, @coin_relation の代入部分を治す
end


