include CoinUtil

ActiveAdmin.register User do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end
  index do
  	column 'id',  :sortable => :id do |f|
      link_to f.id, admin_user_path(f)
    end
  	column 'email', :email

  	coins = coin_list_i
  	coins.each do | co |
    	column Cointype.find( co ).ticker , :sortable => :id do |f|
    		Acnt.find_by(user_id: f.id, cointype_id: co).balance
  	  end
  	end

    tick1 = [ "BTC", "BTC", "BTC", "LTC", "LTC", "MONA"]
    tick2 = [ "LTC", "MONA", "DOGE", "MONA", "DOGE", "DOGE"]
    6.times do | i |      
      column tick1[i] + '-' + tick2[i], :sortable => :id do |f|
        coin1id = Cointype.find_by( ticker: tick1[i]).id
        coin2id = Cointype.find_by( ticker: tick2[i]).id
        f.order.openor.coins(coin1id, coin2id).count
        # orders = f.order.openor.coins(coin1id, coin2id)
        # link_to orders.count, admin_orders_path(orders)
      end
    end
  end
end
