class OpenOrder

  include ActiveModel::Model  #form_for を使うのに必要

  attr_accessor :user_id, :coin1, :coin2, :pr, :steprate, :num, :eachamt, :updown

  def initialize(user_id: 1, coin1: 1, coin2: 2, pr: 100, steprate: 1, num: 5, eachamt: 1.0, updown: 0)
    @user_id = user_id.to_i 
    @coin1 = coin1.to_i
    @coin2 = coin2.to_i
    @pr = pr.to_f
    @steprate = steprate.to_f
    @num = num.to_i
    @eachamt = eachamt.to_f
    @updown = updown.to_i  # both: 0, up(sell): 1, down(buy):2
  end

end


