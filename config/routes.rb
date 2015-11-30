# == Route Map
#
#                       Prefix Verb   URI Pattern                                 Controller#Action
#                   admin_root GET    /admin(.:format)                            admin/dashboard#index
#              admin_dashboard GET    /admin/dashboard(.:format)                  admin/dashboard#index
#     batch_action_admin_users POST   /admin/users/batch_action(.:format)         admin/users#batch_action
#                  admin_users GET    /admin/users(.:format)                      admin/users#index
#                              POST   /admin/users(.:format)                      admin/users#create
#               new_admin_user GET    /admin/users/new(.:format)                  admin/users#new
#              edit_admin_user GET    /admin/users/:id/edit(.:format)             admin/users#edit
#                   admin_user GET    /admin/users/:id(.:format)                  admin/users#show
#                              PATCH  /admin/users/:id(.:format)                  admin/users#update
#                              PUT    /admin/users/:id(.:format)                  admin/users#update
#                              DELETE /admin/users/:id(.:format)                  admin/users#destroy
#               admin_comments GET    /admin/comments(.:format)                   admin/comments#index
#                              POST   /admin/comments(.:format)                   admin/comments#create
#                admin_comment GET    /admin/comments/:id(.:format)               admin/comments#show
#                              DELETE /admin/comments/:id(.:format)               admin/comments#destroy
#                  rails_admin        /kanrishapeizi                              RailsAdmin::Engine
#      admins_precheck_service GET    /admins/precheck_service                    admins#precheck_service
#        admins_orderbook_exec GET    /admins/orderbook_exec                      admins#orderbook_exec
#  admins_orderbook_trade2acnt GET    /admins/orderbook_trade2acnt                admins#orderbook_trade2acnt
#        admins_orderbook_plot GET    /admins/orderbook_plot                      admins#orderbook_plot
#       admins_orderbook_total GET    /admins/orderbook_total                     admins#orderbook_total
#        admins_pricehist_exec GET    /admins/pricehist_exec                      admins#pricehist_exec
#        admins_pricehist_plot GET    /admins/pricehist_plot                      admins#pricehist_plot
#       admins_pricehist_total GET    /admins/pricehist_total                     admins#pricehist_total
#      admins_walletcheck_exec GET    /admins/walletcheck_exec                    admins#walletcheck_exec
#        admins_test_email_new GET    /admins/test_email_new                      admins#test_email_new
#     admins_test_email_create POST   /admins/test_email_create                   admins#test_email_create
#   admins_index_order_btc_ltc GET    /admins/index_order_btc_ltc                 admins#index_order_btc_ltc
#  admins_index_order_btc_mona GET    /admins/index_order_btc_mona                admins#index_order_btc_mona
#  admins_index_order_btc_doge GET    /admins/index_order_btc_doge                admins#index_order_btc_doge
#  admins_index_order_ltc_mona GET    /admins/index_order_ltc_mona                admins#index_order_ltc_mona
#  admins_index_order_ltc_doge GET    /admins/index_order_ltc_doge                admins#index_order_ltc_doge
# admins_index_order_mona_doge GET    /admins/index_order_mona_doge               admins#index_order_mona_doge
#                closed_orders POST   /closed_orders                              closed_orders#create
#            new_closed_orders GET    /closed_orders/new                          closed_orders#new
#     closed_orders_delete_new GET    /closed_orders/delete_new                   closed_orders#delete_new
#   closed_orders_delete_check POST   /closed_orders/delete_check                 closed_orders#delete_check
#  closed_orders_delete_create POST   /closed_orders/delete_create                closed_orders#delete_create
#                  open_orders POST   /open_orders                                open_orders#create
#              new_open_orders GET    /open_orders/new                            open_orders#new
#    admins_autotrade_checkweb GET    /admins/autotrade_checkweb                  admins#autotrade_checkweb
#                              GET    /:locale                                    orders#btc_ltc
#                         root GET    /(:locale)                                  orders#btc_ltc {:locale=>/ja|en/}
#               orders_btc_ltc GET    (/:locale)/orders/btc_ltc                   orders#btc_ltc {:locale=>/ja|en/}
#              orders_btc_mona GET    (/:locale)/orders/btc_mona                  orders#btc_mona {:locale=>/ja|en/}
#              orders_btc_doge GET    (/:locale)/orders/btc_doge                  orders#btc_doge {:locale=>/ja|en/}
#              orders_ltc_mona GET    (/:locale)/orders/ltc_mona                  orders#ltc_mona {:locale=>/ja|en/}
#              orders_ltc_doge GET    (/:locale)/orders/ltc_doge                  orders#ltc_doge {:locale=>/ja|en/}
#             orders_mona_doge GET    (/:locale)/orders/mona_doge                 orders#mona_doge {:locale=>/ja|en/}
#     static_pages_explanation GET    (/:locale)/static_pages/explanation         static_pages#explanation {:locale=>/ja|en/}
#     static_pages_contact_new GET    (/:locale)/static_pages/contact_new         static_pages#contact_new {:locale=>/ja|en/}
#  static_pages_contact_create POST   (/:locale)/static_pages/contact_create      static_pages#contact_create {:locale=>/ja|en/}
#                   users_edit GET    (/:locale)/users/edit(.:format)             users/registrations#edit {:locale=>/ja|en/}
#                users_sign_up GET    (/:locale)/users/sign_up(.:format)          users/registrations#new {:locale=>/ja|en/}
#                users_sign_in GET    (/:locale)/users/sign_in(.:format)          users/sessions#new {:locale=>/ja|en/}
#                        users POST   (/:locale)/users(.:format)                  users/registrations#create {:locale=>/ja|en/}
#             new_user_session GET    (/:locale)/users/sign_in(.:format)          devise/sessions#new {:locale=>/ja|en/}
#                 user_session POST   (/:locale)/users/sign_in(.:format)          devise/sessions#create {:locale=>/ja|en/}
#         destroy_user_session DELETE (/:locale)/users/sign_out(.:format)         devise/sessions#destroy {:locale=>/ja|en/}
#                user_password POST   (/:locale)/users/password(.:format)         devise/passwords#create {:locale=>/ja|en/}
#            new_user_password GET    (/:locale)/users/password/new(.:format)     devise/passwords#new {:locale=>/ja|en/}
#           edit_user_password GET    (/:locale)/users/password/edit(.:format)    devise/passwords#edit {:locale=>/ja|en/}
#                              PATCH  (/:locale)/users/password(.:format)         devise/passwords#update {:locale=>/ja|en/}
#                              PUT    (/:locale)/users/password(.:format)         devise/passwords#update {:locale=>/ja|en/}
#     cancel_user_registration GET    (/:locale)/users/cancel(.:format)           devise/registrations#cancel {:locale=>/ja|en/}
#            user_registration POST   (/:locale)/users(.:format)                  devise/registrations#create {:locale=>/ja|en/}
#        new_user_registration GET    (/:locale)/users/sign_up(.:format)          devise/registrations#new {:locale=>/ja|en/}
#       edit_user_registration GET    (/:locale)/users/edit(.:format)             devise/registrations#edit {:locale=>/ja|en/}
#                              PATCH  (/:locale)/users(.:format)                  devise/registrations#update {:locale=>/ja|en/}
#                              PUT    (/:locale)/users(.:format)                  devise/registrations#update {:locale=>/ja|en/}
#                              DELETE (/:locale)/users(.:format)                  devise/registrations#destroy {:locale=>/ja|en/}
#            user_confirmation POST   (/:locale)/users/confirmation(.:format)     devise/confirmations#create {:locale=>/ja|en/}
#        new_user_confirmation GET    (/:locale)/users/confirmation/new(.:format) devise/confirmations#new {:locale=>/ja|en/}
#                              GET    (/:locale)/users/confirmation(.:format)     devise/confirmations#show {:locale=>/ja|en/}
#                  user_unlock POST   (/:locale)/users/unlock(.:format)           devise/unlocks#create {:locale=>/ja|en/}
#              new_user_unlock GET    (/:locale)/users/unlock/new(.:format)       devise/unlocks#new {:locale=>/ja|en/}
#                              GET    (/:locale)/users/unlock(.:format)           devise/unlocks#show {:locale=>/ja|en/}
#         orders_index_btc_ltc GET    (/:locale)/orders/index_btc_ltc             orders#index_btc_ltc {:locale=>/ja|en/}
#        orders_index_btc_mona GET    (/:locale)/orders/index_btc_mona            orders#index_btc_mona {:locale=>/ja|en/}
#        orders_index_btc_doge GET    (/:locale)/orders/index_btc_doge            orders#index_btc_doge {:locale=>/ja|en/}
#        orders_index_ltc_mona GET    (/:locale)/orders/index_ltc_mona            orders#index_ltc_mona {:locale=>/ja|en/}
#        orders_index_ltc_doge GET    (/:locale)/orders/index_ltc_doge            orders#index_ltc_doge {:locale=>/ja|en/}
#       orders_index_mona_doge GET    (/:locale)/orders/index_mona_doge           orders#index_mona_doge {:locale=>/ja|en/}
#                       orders POST   (/:locale)/orders                           orders#create {:locale=>/ja|en/}
#                   edit_order GET    (/:locale)/orders/:id/edit                  orders#edit {:locale=>/ja|en/}
#                        order GET    (/:locale)/orders/:id                       orders#show {:locale=>/ja|en/}
#                              PATCH  (/:locale)/orders/:id                       orders#update {:locale=>/ja|en/}
#                              PUT    (/:locale)/orders/:id                       orders#update {:locale=>/ja|en/}
#                   acnts_show GET    (/:locale)/acnts/show                       acnts#show {:locale=>/ja|en/}
#           coinios_coinio_btc GET    (/:locale)/coinios/coinio_btc               coinios#coinio_btc {:locale=>/ja|en/}
#           coinios_coinio_ltc GET    (/:locale)/coinios/coinio_ltc               coinios#coinio_ltc {:locale=>/ja|en/}
#          coinios_coinio_mona GET    (/:locale)/coinios/coinio_mona              coinios#coinio_mona {:locale=>/ja|en/}
#          coinios_coinio_doge GET    (/:locale)/coinios/coinio_doge              coinios#coinio_doge {:locale=>/ja|en/}
#                      coinios POST   (/:locale)/coinios                          coinios#create {:locale=>/ja|en/}
#                       coinio GET    (/:locale)/coinios/:id                      coinios#show {:locale=>/ja|en/}
#                              GET    (/:locale)/*anything(.:format)              orders#btc_ltc {:locale=>/ja|en/}
#
# Routes for RailsAdmin::Engine:
#   dashboard GET         /                                      rails_admin/main#dashboard
#       index GET|POST    /:model_name(.:format)                 rails_admin/main#index
#         new GET|POST    /:model_name/new(.:format)             rails_admin/main#new
#      export GET|POST    /:model_name/export(.:format)          rails_admin/main#export
# bulk_delete POST|DELETE /:model_name/bulk_delete(.:format)     rails_admin/main#bulk_delete
# bulk_action POST        /:model_name/bulk_action(.:format)     rails_admin/main#bulk_action
#        show GET         /:model_name/:id(.:format)             rails_admin/main#show
#        edit GET|PUT     /:model_name/:id/edit(.:format)        rails_admin/main#edit
#      delete GET|DELETE  /:model_name/:id/delete(.:format)      rails_admin/main#delete
# show_in_app GET         /:model_name/:id/show_in_app(.:format) rails_admin/main#show_in_app
#

Rails.application.routes.draw do


  ActiveAdmin.routes(self)
  mount RailsAdmin::Engine => '/kanrishapeizi', as: 'rails_admin'
  # 前の方のおかないと、このパスが、localeと勘違いされて、routingのエラーとなる。

  get  'admins/precheck_service', format: false
  get  'admins/orderbook_exec', format: false
  get  'admins/orderbook_trade2acnt', format: false
  get  'admins/orderbook_plot', format: false
  get  'admins/orderbook_total', format: false
  get  'admins/pricehist_exec', format: false
  get  'admins/pricehist_plot', format: false
  get  'admins/pricehist_total', format: false
  get  'admins/walletcheck_exec', format: false
  get  'admins/test_email_new', format: false
  post 'admins/test_email_create', format: false

  get  'admins/index_order_btc_ltc', format: false
  get  'admins/index_order_btc_mona', format: false
  get  'admins/index_order_btc_doge', format: false
  get  'admins/index_order_ltc_mona', format: false
  get  'admins/index_order_ltc_doge', format: false
  get  'admins/index_order_mona_doge', format: false

  resource :closed_orders, only: [:new, :create], format: false
  get  'closed_orders/delete_new', format: false
  post 'closed_orders/delete_check', format: false
  post 'closed_orders/delete_create', format: false

  resource :open_orders, only: [:new, :create], format: false

  get  'admins/autotrade_checkweb', format: false

  match '/:locale' => 'orders#btc_ltc', via: [ :get ], format: false

  scope "(:locale)", locale: /ja|en/ do 

    root 'orders#btc_ltc', format: false
 
    get  'orders/btc_ltc', format: false
    get  'orders/btc_mona', format: false
    get  'orders/btc_doge', format: false
    get  'orders/ltc_mona', format: false
    get  'orders/ltc_doge', format: false
    get  'orders/mona_doge', format: false
 
    get  'static_pages/explanation', format: false
    get  'static_pages/contact_new', format: false
    post 'static_pages/contact_create', format: false

    # post 'orders/create'
    # patch 'orders/create'
    devise_scope :user do
      get  'users/edit', to: 'users/registrations#edit'
      get  'users/sign_up', to: 'users/registrations#new'
      get  'users/sign_in', to: 'users/sessions#new'
      post 'users', to: 'users/registrations#create'
    end
    devise_for :users, except: [ :destroy ] #どうもうまく消えてないようだ。

    get  'orders/index_btc_ltc', format: false
    get  'orders/index_btc_mona', format: false
    get  'orders/index_btc_doge', format: false
    get  'orders/index_ltc_mona', format: false
    get  'orders/index_ltc_doge', format: false
    get  'orders/index_mona_doge', format: false

    # get  'orders/create', to: 'orders#btc_ltc'  
    # # order の入力でエラーが起こった後、言語を変更すると、
    # # 誤って、order#show を呼ぶ。
    # # それを回避するための、routing

    resources :orders, only: [:create, :show, :edit, :update], format: false

    get  'acnts/show', format: false

    get  'coinios/coinio_btc', format: false
    get  'coinios/coinio_ltc', format: false
    get  'coinios/coinio_mona', format: false
    get  'coinios/coinio_doge', format: false
    # post 'coinios/create'
    # get 'coinios/create', to: 'orders#btc_ltc'  
    # coinio の入力でエラーが起こった後、言語を変更すると、
    # coinios/create [get] が見つからない
    # というroutingのエラーが起こる。
    # それを回避するための、routing

    resources :coinios, only: [:create, :show], format: false

    get '*anything' => 'orders#btc_ltc'
  end

  # get'/en/coinios/create' => 'orders#btc_mona', locale: en 
  # get'/ja/coinios/create' => 'orders#btc_mona', locale: ja

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
