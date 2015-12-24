require 'rails_helper'
require 'support/execute_test' # suppport が必要
# require 'lib/usrclasses/orderbook.rb'

describe "BookMake" do
  coin1 = FactoryGirl.create(:bitcoin)
  coin2 = FactoryGirl.create(:litecoin)
  coin3 = FactoryGirl.create(:monacoin)
  coin4 = FactoryGirl.create(:dogecoin)

  FactoryGirl.create(:coin_relation, coin_a: coin1, coin_b: coin2, 
      step_min: 10, book_trig: 30, book_range: 60)
  FactoryGirl.create(:coin_relation, coin_a: coin1, coin_b: coin3)
  FactoryGirl.create(:coin_relation, coin_a: coin1, coin_b: coin4)
  FactoryGirl.create(:coin_relation, coin_a: coin2, coin_b: coin3)
  FactoryGirl.create(:coin_relation, coin_a: coin2, coin_b: coin4)
  FactoryGirl.create(:coin_relation, coin_a: coin3, coin_b: coin4)

  user0 = FactoryGirl.create(:admin)
  user1 = FactoryGirl.create(:user)
  user2 = FactoryGirl.create(:user)
  user3 = FactoryGirl.create(:user)

  describe "create_openor" do
    describe "control" do
      before {
        FactoryGirl.create(:acnt, user: user0, cointype: coin1, balance: 100, locked_bal: 0)
        FactoryGirl.create(:acnt, user: user0, cointype: coin2, balance: 10000, locked_bal: 0)        
      }

      it "check controller" do
        cr = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
        BookMake.create_openor(cr, true, 6000, 6050, 0.1)
        BookMake.create_openor(cr, false, 6000, 5950, 0.1)

        ex = ExecuteTest.new(coin1, coin2)
        ex.show_data
        BookMake.control
        ex.show_data

        ex.file_close
      end

      # it "upwards, sell, within amt limit " do
      #   cr = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
      #   BookMake.create_openor(cr, false, , 100, 1)
      #   ex = ExecuteTest.new(coin1, coin2)
      #   ex.show_data
      #   ex.file_close
      # end

    # describe "no orders at initial" do
    #   before {
    #     FactoryGirl.create(:acnt, user: user0, cointype: coin1, balance: 10, locked_bal: 0)
    #     FactoryGirl.create(:acnt, user: user0, cointype: coin2, balance: 1000, locked_bal: 0)
    #   }

    #   it "upwards, sell, within amt limit " do
    #     FactoryGirl.create(:order, coin_a: coin1, coin_b: coin2, user: user1, buysell: false, 
    #       amt_a: 1, amt_a_org: 1, amt_b: 102, amt_b_org: 102, rate: 102)
    #     FactoryGirl.create(:order, coin_a: coin1, coin_b: coin2, user: user1, buysell: false, 
    #       amt_a: 1, amt_a_org: 1, amt_b: 103, amt_b_org: 103, rate: 103)

    #     cr = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
    #     BookMake.create_openor(cr,  114, 100, false, 1)
    #     ex = ExecuteTest.new(coin1, coin2) 
    #     ex.show_data
    #     ex.file_close
    #   end

      # it "upwards, sell, out of amt limit" do
      #   cr = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
      #   BookMake.create_openor(cr, 115, 100, true,1)
      #   ex = ExecuteTest.new(coin1, coin2) 
      #   ex.show_data
      #   ex.file_close
      # end
      
      # it "upwards, buy, within amt limit " do
      #   cr = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
      #   BookMake.create_openor(cr, 105, 100, false, 1)
      #   ex = ExecuteTest.new(coin1, coin2) 
      #   ex.show_data
      #   ex.file_close
      # end

      # it "upwards, buy, out of amt limit" do
      #   cr = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
      #   BookMake.create_openor(cr, 115, 100,  false, 1)
      #   ex = ExecuteTest.new(coin1, coin2) 
      #   ex.show_data
      #   ex.file_close
      # end
    end
  end
end

=begin
  describe "cancel_openor" do
    describe "rate up, sell" do
      it "rate up, sell, within" do
        ex = ExecuteTest.new(coin1, coin2)        
        ex.find_no(1)
        ex.read_data_create_orders
        cr = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
        BookMake.cancel_openor(cr, 102, true, true)
        ex.show_data
        ex.file_close
      end

      it "rate up, sell, out of " do
        ex = ExecuteTest.new(coin1, coin2)        
        ex.find_no(1)
        ex.read_data_create_orders
        cr = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
        BookMake.cancel_openor(cr, 110, true, true)
        ex.show_data
        ex.file_close
      end
    end

    describe "rate up, buy" do
      it "rate up, buy, within" do
        ex = ExecuteTest.new(coin1, coin2)        
        ex.find_no(1)
        ex.read_data_create_orders
        cr = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
        BookMake.cancel_openor(cr, 97, true, false)
        ex.show_data
        ex.file_close
      end

      it "rate up, buy, out of " do
        ex = ExecuteTest.new(coin1, coin2)        
        ex.find_no(1)
        ex.read_data_create_orders
        cr = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
        BookMake.cancel_openor(cr, 101, true, false)
        ex.show_data
        ex.file_close
      end
    end

    describe "rate down, sell" do
      it "rate down, sell, within" do
        ex = ExecuteTest.new(coin1, coin2)        
        ex.find_no(1)
        ex.read_data_create_orders
        cr = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
        BookMake.cancel_openor(cr, 102, false, true)
        ex.show_data
        ex.file_close
      end

      it "rate down, sell, out of " do
        ex = ExecuteTest.new(coin1, coin2)        
        ex.find_no(1)
        ex.read_data_create_orders
        cr = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
        BookMake.cancel_openor(cr, 98, false, true)
        ex.show_data
        ex.file_close
      end
    end

    describe "rate down, buy" do
      it "rate down, sell, within" do
        ex = ExecuteTest.new(coin1, coin2)        
        ex.find_no(1)
        ex.read_data_create_orders
        cr = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
        BookMake.cancel_openor(cr, 98, false, false)
        ex.show_data
        ex.file_close
      end

      it "rate down, sell, buy, out of" do
        ex = ExecuteTest.new(coin1, coin2)        
        ex.find_no(1)
        ex.read_data_create_orders
        cr = CoinRelation.find_by(coin_a: coin1, coin_b: coin2)
        BookMake.cancel_openor(cr, 90, false, false)
        ex.show_data
        ex.file_close
      end
    end

  end

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
=end
