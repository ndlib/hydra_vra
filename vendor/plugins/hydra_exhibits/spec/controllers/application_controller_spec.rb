require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do

# HEAD CONTENT
  describe "base assets from variables" do
    it "should include #base assets before_filter" do
       controller.class.filter_chain.to_a.find {|f| f.method == :base_assets && f.options=={} }.should_not be_nil
    end
    it "should skip #default_head_html before_filter" do
       controller.class.filter_chain.to_a.find {|f| f.method == :default_head_htms && f.options=={} }.should be_nil
    end
    describe "#base assets" do
      before(:each) do
        controller.send(:base_assets)
      end
      it "should setup js and css defaults" do
        controller.javascript_includes.should include(['application'])
        controller.javascript_includes.should include(['blacklight', 'application', 'accordion', { :plugin=>:blacklight }])
        controller.javascript_includes.should include(['http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js', 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js'])
        
        controller.stylesheet_links.should include(['yui', {:plugin => :hydra_exhibits, :media=>'all'}])
        controller.stylesheet_links.should include(['redmond/jquery-ui-1.8.5.custom', {:media=>'all'}])
        controller.stylesheet_links.should include(['styles', 'hydrangea', 'hydrangea-split-button', {:media=>'all'}])
        controller.stylesheet_links.should include(['application', 'hydra-exhibit', {:plugin => :hydra_exhibits, :media=>'all'}])
      end
    end        
  end

end
