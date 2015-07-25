class ClosedOrder

  include ActiveModel::Model  #form_for を使うのに必要

  attr_accessor :user_id, :coin1, :coin2, :pr, :tmstr, :tmend, :stepmin

  def initialize(user_id: 1, coin1: 1, coin2: 2, pr: 10, tmstr: Time.now , tmend: Time.now, stepmin: 5)
    @user_id = user_id.to_i 
    @coin1 = coin1.to_i
    @coin2 = coin2.to_i
    @pr = pr.to_f
    @tmstr = tmstr.is_a?(Time) ? tmstr : Time.parse(tmstr)
    @tmend = tmend.is_a?(Time) ? tmend : Time.parse(tmend) 
    @stepmin = stepmin.to_i
  end

end


