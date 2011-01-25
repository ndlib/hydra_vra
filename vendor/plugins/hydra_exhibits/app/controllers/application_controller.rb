class ApplicationController 
  skip_before_filter :default_html_head
  before_filter :base_assets

  #############
  # Display-related methods. 
  #############
  
  # Because of the way Hydra Repository Application controller is included is is difficult to override.
  # The base_assets method sidesteps this problem but does not solve it.
  # Ideally the default_html_head method could be overriden here.
  def base_assets
    # when working offline, comment out the above uncomment the next line:
    #javascript_includes << ['jquery-1.4.2.min.js', 'jquery-ui-1.8.1.custom.min.js', { :plugin=>:blacklight } ]
  
    javascript_includes << ['http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js', 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js']
    javascript_includes << ['application']
    javascript_includes << ['blacklight', 'application', 'accordion', { :plugin=>:blacklight } ]
    
    stylesheet_links << ['yui', 'application', {:plugin=>:blacklight, :media=>'all'}]
    stylesheet_links << ['redmond/jquery-ui-1.8.5.custom', {:media=>'all'}]      
    stylesheet_links << ['styles', 'hydrangea', 'hydrangea-split-button','hydraExhibit', {:media=>'all'}]
  end
end
