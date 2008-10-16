ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"
  # this gives us a create_index_url
  #map.create_index 'create/', :controller => 'create', :action => 'index'
  
  map.root :controller => 'static_page', :page => 'home'
  map.connect ':page/', :controller => 'static_page', :requirements => { :page => /(#{STATIC_PAGES.join('|')})/i }
  
  map.connect 'library/feed.:format', :controller => 'library', :action => 'index', :conditions => { :method => :get }, :requirements => { :format => /atom|rss/ }
  map.connect 'library/', :controller => 'library', :action => 'index'  
  map.connect 'library/:id', :controller => 'library', :action => 'view_piece'  
  
  map.connect 'compose/', :controller => 'compose', :action => 'index'  
  map.connect 'compose/:user_submission_id', :controller => 'compose', :action => 'index', :user_submission_id => /\d+/
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'    
end
