require 'spec_helper'
# require 'lib/usrclasses/orderbook.rb'

describe "orderbook" do
  coin1 = FactoryGirl.create(:bitcoin)
  coin2 = FactoryGirl.create(:litecoin)
  coin3 = FactoryGirl.create(:monacoin)
  coin4 = FactoryGirl.create(:dogecoin)

  FactoryGirl.create(:coin_relation, coin_a: coin1, coin_b: coin2)
  FactoryGirl.create(:coin_relation, coin_a: coin1, coin_b: coin3)
  FactoryGirl.create(:coin_relation, coin_a: coin1, coin_b: coin4)
  FactoryGirl.create(:coin_relation, coin_a: coin2, coin_b: coin3)
  FactoryGirl.create(:coin_relation, coin_a: coin2, coin_b: coin4)
  FactoryGirl.create(:coin_relation, coin_a: coin3, coin_b: coin4)

  order = FactoryGirl.create(:order, coin_a: coin1, coin_b: coin2)

  # user = FactoryGirl.create(:user)
  # order = FactoryGirl.create(:order, user: user, coin_a: coin1, coin_b: coin2)

  # it "to check incraese of No. of orders" do
  #   expect{ 
  #     order = FactoryGirl.create(:order, user: user, coin_a: coin1, coin_b: coin2)
  #         .to change(Order, :count).by(1)
  #   }
  # end

end
