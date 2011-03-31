ActionController::Routing::Routes.draw do |map|  
  
  # Load Blacklight's routes and add edit_catalog named route
  Blacklight::Routes.build map
  map.edit_catalog 'catalog/:id/edit', :controller=>:catalog, :action=>:edit
  
  #map.root :controller => 'collections', :action=>'index'
  # map.resources :assets do |assets|
  #   assets.resources :downloads, :only=>[:index]
  # end
  map.resources :get, :only=>:show  
  map.resources :webauths, :protocol => ((defined?(SSL_ENABLED) and SSL_ENABLED) ? 'https' : 'http')
  map.resources :components
  map.resources :images_tag
  map.resources :descriptions, {:member => {:add=> :put, :update_title => :put } }
  map.resources :collections
  map.resources :sub_exhibits
  map.resources :exhibits, {:member => {:update_embedded_search=> :post, :add_main_description=> :put, :add_collection=> :put, :remove_collection=> :post, :refresh_setting=> :get}}
  map.resources :pages
#  map.static 'static/:permalink', :controller => 'finding_aid', :action => 'show'
  map.resources :finding_aid, :controller => 'finding_aid' , :action => 'show', :finding_aid => /show|collection/

  map.login "login", :controller => "webauth_sessions", :action => "new"
  map.logout "logout", :controller => "webauth_sessions", :action => "destroy"

end
