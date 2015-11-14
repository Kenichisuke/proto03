require 'rails_helper'

describe OrderCreate do

  coin1 = FactoryGirl.create(:bitcoin)
  coin2 = FactoryGirl.create(:litecoin)
  # coin3 = FactoryGirl.create(:monacoin)
  # coin4 = FactoryGirl.create(:dogecoin)

  let!( :user ) { FactoryGirl.create(:user) }
  let!( :acnt1 ) { FactoryGirl.create(:acnt, user: user, cointype: coin1)}
  let!( :acnt2 ) { FactoryGirl.create(:acnt, user: user, cointype: coin2)}
  let( :order_create ) { OrderCreate.new( order ) }

  describe "order with ok data" do
    context "order amount within account" do
      let( :order ) { FactoryGirl.build(:order, user: user, coin_a: coin1, coin_b: coin2) }      
      it "preparation of transaction, return true" do
        expect( order_create.prep_acnt_with_order? ).to eq true
      end
      it "save order and acnt, will success" do
        order_create.prep_acnt_with_order?
        expect{ order_create.save_new_order_with_acnt! }.to change(Order, :count).by(1)
      end
      it "save order. acnt locked_bal change" do
        order_create.prep_acnt_with_order?
        order_create.save_new_order_with_acnt!
        expect{ acnt1.reload }.to change(acnt1, :locked_bal).by(1)
      end
      # important !!!!!!!

      context "failure of new order, Database transaction error" do
        before {
          expect( order_create ).to receive( :transaction_order_acnt ).at_least(:once) { raise 'Hello, this is test!' }
          order_create.prep_acnt_with_order?
        }
        it "save order and acnt, but fail and throw exception" do
          expect { order_create.save_new_order_with_acnt! }.to raise_error( 'Hello, this is test!' )
        end

        it "try to save new order. but fail. NO. of order unchange" do
          cnt = Order.count
          begin
            order_create.save_new_order_with_acnt!
          rescue
            expect( Order.count - cnt ).to eq(0)
          end
        end

        it "try to save new order. but fail. Acnt locked_bal unchange" do
          begin
            order_create.save_new_order_with_acnt!
          rescue
            expect( acnt1.locked_bal ).to eq( 0 )
          end
        end
      end
    end
      
    context "order amount bigger than account" do
      let( :order ) { FactoryGirl.build(:order, user: user, coin_a: coin1, coin_b: coin2, 
        rate: 101, buysell: false, amt_b: 101, amt_b_org: 101) }
      it "preparation of transaction, return true or false" do
        expect( order_create.prep_acnt_with_order? ).to eq false
      end
      it "save order and acnt, will give exception" do
        order_create.prep_acnt_with_order?
        expect{ order_create.save_new_order_with_acnt! }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end
    
