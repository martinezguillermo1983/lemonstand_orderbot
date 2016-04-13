Rails.application.routes.draw do
  get     '/'               => 'root#show'

  get     'sessions/new'

  get     'users/new'

  get     'login'           => 'sessions#new'
  post    'login'           => 'sessions#create'
  get     'logout'          => 'sessions#destroy'

  get     'products'        => 'sync#products' 
  get     'setup'           => 'setup#show'

  get 'orderbotclient/:client_code/clientslinks' => 'clients_link#getOrderBotClientsLinks'
  get 'orderbotclient/:client_code/clientslinks/options' => 'clients_link#getOptions'
  put 'clientslinks/:clients_link_id' => 'clients_link#updateClientsLink'

  get 'orderbotclient/:client_code/productclasses/'  => 'product#getProductClasses'
  get 'orderbotclient/:client_code/productclasses/:product_class_id/categories/'  => 'product#getProductCategoriesByProductClass'
  get 'orderbotclient/:client_code/products'  => 'product#getProducts' 
  post 'orderbotclient/:client_code/sync/products'  => 'product#sync'
  namespace :api do
    namespace :v1 do
      post 'stockcheck/:client_code'  => 'order#stockCheck'
      post 'sync/order/:client_code'     => 'order#sync'
      post 'sync/customer/:client_code'  => 'customer#sync'
    end
  end

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
