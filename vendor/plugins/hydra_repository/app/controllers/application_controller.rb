#
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#

# Load Blacklight's ApplicationController first
require_dependency "vendor/plugins/blacklight/app/controllers/application_controller.rb"

class ApplicationController 
  
  include HydraAccessControlsHelper
  
  helper :all
  helper :hydra_access_controls, :hydra_djatoka, :downloads, :metadata, :hydra, :custom_metadata, :hydra_fedora_metadata, :hydra_assets
  helper :generic_content_objects, :personalization, :hydrangea_datasets
  
  # helper_method [:request_is_for_user_resource?]#, :user_logged_in?]
  before_filter [:store_bounce]
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # protect_from_forgery # :secret => '200c1e5f25e610288439b479ef176bbd'
  
  
  def default_html_head
    # when working offline, comment out the above uncomment the next line:
    #javascript_includes << ['jquery-1.4.2.min.js', 'jquery-ui-1.8.1.custom.min.js', { :plugin=>:blacklight } ]
  
    javascript_includes << ['http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js', 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js']
    javascript_includes << ['application']
    
    javascript_includes << ['blacklight', 'application', 'accordion', { :plugin=>:blacklight } ]
    
    stylesheet_links << ['yui', 'application', {:plugin=>:blacklight, :media=>'all'}]
    stylesheet_links << ['redmond/jquery-ui-1.8.5.custom', {:media=>'all'}]      
    stylesheet_links << ['styles', 'hydrangea', 'hydrangea-split-button','hydraExhibit', {:media=>'all'}]
  end 
      
=begin
def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
    @current_user.extend(Hydra::SuperuserAttributes)
  end
=end
  def current_user
    return @current_user if defined?(@current_user)
    if session[:cas_user]
      logger.debug("User from cas")
      @current_user = User.find_or_create_user_by_login(session[:cas_user])
      logger.debug("End of User from cas")
    else
      @current_user = current_user_session && current_user_session.user
    end
    @current_user.extend(Hydra::SuperuserAttributes)
  end
  protected
  def store_bounce 
    session[:bounce]=params[:bounce]
  end

end
