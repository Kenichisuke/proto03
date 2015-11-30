require 'rails_helper'
require 'support/execute_test' # suppport が必要
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

  user0 = FactoryGirl.create(:admin)
  user1 = FactoryGirl.create(:user)
  user2 = FactoryGirl.create(:user)
  user3 = FactoryGirl.create(:user)

  describe "orderbook test" do

    describe "one orderbooking" do
      ex = ExecuteTest.new(coin1, coin2)
      ex.find_no(10)
      ex.read_data_create_orders
      amt_a_before = total_amount_in_acounts(coin1)
      amt_b_before = total_amount_in_acounts(coin2)
      it "before: check order_amt == locked_bal, BTC" do
        check_amount_yet_in_orders_and_aconts(coin1)
      end
      it "before: check order_amt == locked_bal, LTC" do
        check_amount_yet_in_orders_and_aconts(coin2)
      end
      Orderbook.execute(coin1.id, coin2.id)
      Orderbook.trade2acnt
      ex.show_data
      it "after: check order_amt == locked_bal, BTC" do
        check_amount_yet_in_orders_and_aconts(coin1)
      end
      it "after: check order_amt == locked_bal, LTC" do
        check_amount_yet_in_orders_and_aconts(coin2)
      end
      amt_a_after = total_amount_in_acounts(coin1)
      amt_b_after = total_amount_in_acounts(coin2)
      it "total amout of BTC, before vs after" do
        expect(amt_a_before - amt_a_after).to eq(0)
      end
      it "total amout of LTC, before vs after(??)" do
      #   # 実は、Rankの低い通貨の合計値は保証されない。
      #   # どんとん小さくなっていく可能性がある。
        puts (amt_b_before - amt_b_after).to_s
        expect(amt_b_before - amt_b_after).to be >= 0
      end
      it "total check" do
        puts "total check is here"
        tmp = ex.check_data
        expect( tmp ).to eq(true)
      end
    end
  end

end
