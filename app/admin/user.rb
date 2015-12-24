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

    crs = CoinRelation.all
    crs.each do | cr |
      column cr.coin_a.ticker + '-' + cr.coin_b.ticker, :sortable => :id do |f|
        if f.orders then
          f.orders.openor.coin_rel(cr).count
        else
          0
        end
      end
    end
  end
end
