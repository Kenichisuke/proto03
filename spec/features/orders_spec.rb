require 'rails_helper'



describe OrdersController do

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

  # user = FactoryGirl.create(:user)
  # user2 = FactoryGirl.create(:user)
  # acnt2 = user2.acnt.find_by(cointype_id: coin2.id)
  # acnt2.locked_bal = 50
  # acnt2.save

  # describe "check setting" do
  #   it "No. of cointype" do
  #     expect(Cointype.count).to eq 4
  #   end
  #   it "check No. of acnts" do
  #     expect(user.acnt.count).to eq 4
  #   end
  # end

  # it "check" do
  #   puts page.body
  #   save_and_open_page
  # end


  describe "visit root_path" do
    before{ visit root_path }
    it "<h1>trade</h1>, contact on root page" do
      expect(page).to have_selector('h1', text: I18n.t('order.trade')) 
      expect(page).to have_link( I18n.t('header.contact') ) 
    end
  end

  describe "creation of order" do
    describe "login with user1 acnts (balance=100, locked_bal=0)" do
      let!( :user ) { FactoryGirl.create(:user) }
      let!( :acnt1 ) { FactoryGirl.create(:acnt, user: user, cointype: coin1)}
      let!( :acnt2 ) { FactoryGirl.create(:acnt, user: user, cointype: coin2)}
      before {
        visit new_user_session_path
        fill_in "メールアドレス", with: user.email
        fill_in "パスワード", with: user.password
        click_button "ログイン"
      }
      it "check page to have success message" do
        expect(page).to have_selector('div.alert.alert-notice.alert-dismissable',  
          text: I18n.t('devise.sessions.signed_in'))
      end
      describe "create orders" do

         # 今の設定では、jsを使ったmodal windowsの確認画面は飛ばして処理されている。
        it "check incraese of No. of orders with right data" do
          fill_in "レート", with: 10
          fill_in "数量", with: 1
          expect{ click_button "「BTC買い/LTC売り」を注文する" }
            .to change(Order, :count).by(1)
        end
        it "check incraese of No. of orders with right data" do
          fill_in "レート", with: 10
          fill_in "数量", with: 1
          click_button "「BTC買い/LTC売り」を注文する"
          expect(page).not_to have_content(I18n.t('errors.messages.order.try_later'))
        end

        describe "check no increase of No. of orders with wrong input (text)" do
          before {
            fill_in "レート", with: 10
            fill_in "数量", with: "Text"
              #ただし、numberと指定してあるため、0に変換するようだ。
          }
          it "check No of orders" do
            expect{ click_button "「BTC買い/LTC売り」を注文する" }
              .not_to change(Order, :count)
          end
          it "check error message" do
            click_button "「BTC買い/LTC売り」を注文する"
            expect(page).to have_content(I18n.t('errors.messages.order.zero_or_negative'))
  #          save_and_open_page
          end
        end
        describe "check no increase of No. of orders with wrong input (text)" do
          before {
            fill_in "レート", with: "text"
            fill_in "数量", with: 1
              #ただし、numberと指定してあるため、0に変換するようだ。
          }
          it "check No of orders" do
            expect{ click_button "「BTC買い/LTC売り」を注文する" }
              .not_to change(Order, :count)
          end
          it "check error message" do
            click_button "「BTC買い/LTC売り」を注文する"
  #          save_and_open_page
            expect(page).to have_content(I18n.t('errors.messages.order.zero_or_negative'))
          end
        end
    
        it "check no increase of No. of orders with wrong input (zero)" do
          fill_in "レート", with: 10
          fill_in "数量", with: 0
          expect{ click_button "「BTC買い/LTC売り」を注文する" }
            .not_to change(Order, :count)
        end  
        it "check no increase of No. of orders with wrong input (zero)" do
          fill_in "レート", with: 0
          fill_in "数量", with: 1
          expect{ click_button "「BTC買い/LTC売り」を注文する" }
            .not_to change(Order, :count)
        end  
        it "check no increase of No. of orders with exccess of amount" do
          fill_in "レート", with: 10
          fill_in "数量", with: 15
          expect{ click_button "「BTC買い/LTC売り」を注文する" }
            .not_to change(Order, :count)
        end

        it "check no increase of No. of orders with exccess of amount (sell btc)" do
          # fill_in "レート", with: 10
          # fill_in "数量", with: 102
          # 同じラベルが２つあるために、うまく動かない。セキュリティーホール。Viewを変更する必要あり。 
          find("#order_rate_s").set(10)
          find("#order_amt_a_s").set(102)
          expect{ click_button "「BTC売り/LTC買い」を注文する" }
            .not_to change(Order, :count)
        end 
      end
    end

    describe "login with user1 acnts (balance=100, locked_bal=45, 50)" do
      let!( :user2 ) { FactoryGirl.create(:user) }
      let!( :acnt3 ) { FactoryGirl.create(:acnt, user: user2, cointype: coin1, locked_bal: 50)}
      let!( :acnt4 ) { FactoryGirl.create(:acnt, user: user2, cointype: coin2, locked_bal: 45)}
      before {
        visit new_user_session_path
        fill_in "メールアドレス", with: user2.email
        fill_in "パスワード", with: user2.password
        click_button "ログイン"
      }
      describe "create order which exceed free_bal" do
        it "check pageto  have error message on order" do
          fill_in "レート", with: 10
          fill_in "数量", with: 6
          click_button "「BTC買い/LTC売り」を注文する"
          expect(page).to have_content(I18n.t('errors.messages.order.free_bal_not_enough'))
        end      
        it "create order which exceed free_bal" do
          fill_in "レート", with: 10
          fill_in "数量", with: 6
          expect{ click_button "「BTC買い/LTC売り」を注文する" }
            .not_to change(Order, :count)
        end
        it "check pageto  have error message on order" do
          # fill_in "レート", with: 1.0
          # fill_in "数量", with: 60
          # 同じラベルが２つあるために、うまく動かない。セキュリティーホール。Viewを変更する必要あり。 
          find("#order_rate_s").set(1)
          find("#order_amt_a_s").set(60)
          click_button "「BTC売り/LTC買い」を注文する"
          # save_and_open_page
          expect(page).to have_content(I18n.t('errors.messages.order.free_bal_not_enough'))
        end
        it "create order which exceed free_bal" do
          # fill_in "レート", with: 1.0
          # fill_in "数量", with: 60
          # 同じラベルが２つあるために、うまく動かない。セキュリティーホール。Viewを変更する必要あり。 
          find("#order_rate_s").set(1)
          find("#order_amt_a_s").set(60)
          click_button "「BTC売り/LTC買い」を注文する"
          expect{ click_button "「BTC売り/LTC買い」を注文する" }
            .not_to change(Order, :count)
        end
      end
    end
  end

  describe "order cancellation" do
    describe "login with user3 (locked_bal=50, free_bal=50)" do 
      let!( :user3 )  { FactoryGirl.create(:user) }
      let!( :acnt5 )  { FactoryGirl.create(:acnt, user: user3, cointype: coin1, locked_bal: 50)}
      let!( :acnt6 )  { FactoryGirl.create(:acnt, user: user3, cointype: coin2, locked_bal: 50)}
      before {
        visit new_user_session_path
        fill_in "メールアドレス", with: user3.email
        fill_in "パスワード", with: user3.password
        click_button "ログイン"
      }
      context  "cancel order (Sell 1 BTC/Buy 10 LTC)" do
        let!( :order1 ) { FactoryGirl.create(:order, user: user3, coin_a: coin1, coin_b: coin2) }
        it "have like to each order show" do
          visit orders_index_btc_ltc_path
          expect(page).to have_link("詳細")
        end
        it "have button for cancellation" do
          visit orders_index_btc_ltc_path
          click_link("詳細")
          expect(page).to have_button("この残存注文をキャンセル")
        end
        it "message" do
          visit orders_index_btc_ltc_path
          click_link("詳細")
          click_button("この残存注文をキャンセル")
          expect(page).to have_content("キャンセルされました")
        end

        it "amount" do
          visit orders_index_btc_ltc_path
          click_link("詳細")
          click_button("この残存注文をキャンセル")
          visit root_path
          expect(page).to have_selector('table tr td', text: '51')
        end
      end
      context "cancel order (buy 1 BTC/sell 10 LTC)" do
        let!( :order2 ) { FactoryGirl.create(:order, user: user3, coin_a: coin1, coin_b: coin2, buysell: false) }
        it "amount" do
          visit orders_index_btc_ltc_path
          click_link("詳細")
          click_button("この残存注文をキャンセル")
          visit root_path
          # save_and_open_page
          expect(page).to have_selector('table tr td', text: '60')
        end
      end        
    end
  end
end
