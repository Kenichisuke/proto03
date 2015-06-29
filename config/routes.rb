Rails.application.routes.draw do


  mount RailsAdmin::Engine => '/kanrishapeizi', as: 'rails_admin'
  # 前の方のおかないと、このパスが、localeと勘違いされて、routingのエラーとなる。

  match '/:locale' => 'orders#btc_mona', via: [ :get ]

  scope "(:locale)", locale: /ja|en/ do 

    root 'orders#btc_mona'
 
    get  'orders/btc_mona'
    get  'orders/btc_ltc'
    get  'orders/ltc_mona'
 
    get  'static_pages/explanation'
    get  'static_pages/contact_new'
    post  'static_pages/contact_create'

    post 'orders/create'
    patch 'orders/create'
    devise_scope :user do
      post 'users', to: 'users/registrations#create'
    end
    devise_for :users, except: [ :destroy ] #どうもうまく消えてないようだ。


    get  'orders/index_btc_mona'
    get  'orders/index_btc_ltc'
    get  'orders/index_ltc_mona'

    get  'orders/create', to: 'orders#btc_mona'  
    # # order の入力でエラーが起こった後、言語を変更すると、
    # # 誤って、order#show を呼ぶ。
    # # それを回避するための、routing

    resources :orders, only: [:show, :edit, :update]

    get  'coinios/coinio_btc'
    get  'coinios/coinio_ltc'
    get  'coinios/coinio_mona'
    post 'coinios/create'

    get 'coinios/create', to: 'orders#btc_mona'  
    # coinio の入力でエラーが起こった後、言語を変更すると、
    # coinios/create [get] が見つからない
    # というroutingのエラーが起こる。
    # それを回避するための、routing
  end


  get  'admins/precheck_service'
  get  'admins/orderbook_exec'
  get  'admins/orderbook_trade2acnt'
  get  'admins/orderbook_plot'
  get  'admins/orderbook_total'
  get  'admins/pricehist_exec'
  get  'admins/pricehist_plot'
  get  'admins/pricehist_total'
  get  'admins/walletcheck_exec'

  get  'admins/index_order_btc_mona'
  get  'admins/index_order_btc_ltc'
  get  'admins/index_order_ltc_mona'

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
