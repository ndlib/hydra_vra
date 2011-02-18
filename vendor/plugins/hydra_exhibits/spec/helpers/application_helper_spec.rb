require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  include ApplicationHelper
  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  include Hydra::AccessControlsEnforcement
  include HydraHelper
  include HydraFedoraMetadataHelper
  include WhiteListHelper
  included ActionView

  before(:all) do
    @resource = mock("fedora object")
    @resource.stubs(:get_values_from_datastream).with("simple_ds", [:title], "").returns( ["title1","title2"] )
    @resource.stubs(:content).returns( "content of the datastream" )
    @resource.stubs(:get_values_from_datastream).with("empty_ds", "something", "").returns( [""] )
  end

  describe "Overridden blacklight methods" do
      #pending "need to write more test""    
  end

#  describe "application_name" do
#    it "should return correct application name" do
#      application_name.should have_text("Hydrangea (ND Demo App)")
#    end
#  end

  describe "collection_field_names" do
    it "should return list of collection field names" do
      response = collection_field_names
      response.should_not be_nil
    end
  end

  describe "collection_field_labels" do
    it "should return list of collection field labels" do
      response = collection_field_labels
      response.should_not be_nil
    end
  end

  describe "item_field_names" do
    it "should return list of collection field names" do
      response = item_field_names
      response.should_not be_nil
    end
  end

  describe "item_field_labels" do
    it "should return list of collection field labels" do
      response = item_field_labels
      response.should_not be_nil
    end
  end

  describe "description_text_area_insert_link" do
    it "should return link to add text area for description" do
      response = description_text_area_insert_link("testdatastream", {:label=>"test label"})
      response.should have_tag("input[data-datastream-name=testdatastream]")
    end
  end

  describe "load_description" do
    it "should return content of the given datastream" do
      mock_description = mock("Description")
      mock_description .stubs(:class).returns(Description)
      Description.expects(:load_instance).with("_PID_").returns(mock_description)
      mock_description.stubs(:id).returns("_PID_")
      mock_description.expects(:content).returns("content of the datastream")
      response = load_description(mock_description)
      response.should == "content of the datastream"
    end
  end

  describe "custom_text_field" do
    before (:each) do
      ActiveFedora::ContentModel.expects(:known_models_for).with(@resource ).returns([Description])
      @resource.stubs(:pid).returns("_PID_")
    end
    it "should generate a text field input with values from the given datastream" do      
      generated_html = custom_text_field(@resource,"simple_ds",[:title],:datastream=>false)      
      generated_html.should have_tag "#title_0-container.custom-editable-container.field"do
        with_tag "span#title_0-text.editable-text.text", "title1"
        with_tag "#title_0.editable-edit.edit" do
          with_tag "[value=?]", "title1"
          with_tag "[name=?]","asset[simple_ds][title][0]"
          with_tag "[data-datastream-name=?]", "simple_ds"
          with_tag "[load-from-datastream=?]", "false"
          with_tag "[rel=?]", "title"
        end
      end
    end
    it "should generate an ordered list of text field inputs" do
      generated_html = custom_text_field(@resource,"simple_ds",[:title],:datastream=>false)
      generated_html.should have_tag "ol[rel=title]" do
        with_tag "li#title_0-container.custom-editable-container.field" do
          without_tag "a.destructive.field"
          with_tag "span#title_0-text.editable-text.text", "title1"
          with_tag "input#title_0.editable-edit.edit" do
            with_tag "[value=?]", "title1"
            with_tag "[name=?]", "asset[simple_ds][title][0]"
            with_tag "[data-datastream-name=?]", "simple_ds"
            with_tag "[load-from-datastream=?]", "false"
            with_tag "[rel=?]", "title"
          end
        end
        with_tag "li#title_1-container.custom-editable-container.field" do
          with_tag "a.destructive.field"
          with_tag "span#title_1-text.editable-text.text", "title2"
          with_tag "input#title_1.editable-edit.edit" do
            with_tag "[value=?]", "title2"
            with_tag "[name=?]", "asset[simple_ds][title][1]"
            with_tag "[data-datastream-name=?]", "simple_ds"
            with_tag "[load-from-datastream=?]", "false"
            with_tag "[rel=?]", "title"
          end
        end
      end
      generated_html.should have_tag "input", :class=>"editable-edit", :id=>"title_1", :name=>"asset[simple_ds][title][1]", :value=>"title2"
    end
    it "should render an empty control if the field has no values" do
      generated_html = custom_text_field(@resource,"empty_ds","something",:datastream=>false)
      #logger.debug("#{generated_html}")
      generated_html.should have_tag "li#something_0-container.custom-editable-container" do        
        with_tag "#something_0-text.editable-text.text", ""
      end
    end
    it "should limit to single-value output with no ordered list if :multiple=>false" do
      generated_html = custom_text_field(@resource,"simple_ds",[:title], :datastream=>false, :multiple=>false)
      generated_html.should_not have_tag "ol"
      generated_html.should_not have_tag "li"

      generated_html.should have_tag "span#title-container.custom-editable-container.field" do
        with_tag "span#title-text.editable-text.text", "title1"
        with_tag "input#title.editable-edit.edit[value=title1]" do
          with_tag "[name=?]", "asset[simple_ds][title][0]"
        end
      end
    end
    it "should generate a text field input with values from the given datastream and load the data from content" do
      #ActiveFedora::ContentModel.expects(:known_models_for).with(@resource ).returns([Description])
      generated_html = custom_text_field(@resource, "simple_datastream", "ds_id", :datastream=>true)
      #logger.debug("#{generated_html}")
      generated_html.should have_tag "#simple_datastream-container.custom-editable-container.field"do
        with_tag "span#simple_datastream-text.editable-text.text", "content of the datastream"
        with_tag "#simple_datastream.editable-edit.edit" do
          with_tag "[value=?]", "content of the datastream"
          with_tag "[name=?]","asset[ds_id][simple_datastream]"
          with_tag "[data-datastream-name=?]", "simple_datastream"
          with_tag "[load-from-datastream=?]", "true"
          with_tag "[rel=?]", "simple_datastream"
        end
      end
  end
    it "should generate an ordered list with content of the first datastream as input for text field" do
      generated_html = custom_text_field(@resource, "simple_datastream", "ds_id", :datastream=>true)
      generated_html.should have_tag "ol[rel=simple_datastream]" do
        with_tag "li#simple_datastream-container.custom-editable-container.field" do
          without_tag "a.destructive.field"
          with_tag "span#simple_datastream-text.editable-text.text", "content of the datastream"
          with_tag "input#simple_datastream.editable-edit.edit" do
            with_tag "[value=?]", "content of the datastream"
            with_tag "[name=?]", "asset[ds_id][simple_datastream]"
            with_tag "[data-datastream-name=?]", "simple_datastream"
            with_tag "[load-from-datastream=?]", "true"
            with_tag "[rel=?]", "simple_datastream"
          end
        end        
      end      
    end
    it "should render an empty control if the field has no values" do      
      @resource .stubs(:content).returns( "" )
      generated_html = custom_text_field(@resource,"empty_ds","something",:datastream=>true)      
      generated_html.should have_tag "li#empty_ds-container.custom-editable-container" do
        with_tag "#empty_ds-text.editable-text.text", ""
      end
    end 
  end
   describe "custom_rich_text_area" do
    before (:each) do
      ActiveFedora::ContentModel.expects(:known_models_for).with(@resource ).returns([Description])
      @resource.stubs(:pid).returns("_PID_")
    end

    it "should generate a textile input with values from the given datastream, normally it is descMetadata" do
      generated_html = custom_rich_text_area(@resource,"simple_ds",[:title],:datastream=>false)      
      generated_html.should have_tag "#title_0-container.custom-textile-container.field"do
        with_tag "div#title_0-text.textile-text.text", "title1"
        with_tag "#title_0.textile-edit.edit" do
          with_tag "[value=?]", "title1"
          with_tag "[name=?]","asset[simple_ds][title][0]"
          with_tag "[data-datastream-name=?]", "simple_ds"
          with_tag "[load-from-datastream=?]", "false"
          with_tag "[rel=?]", "title"
        end
      end
    end
    it "should generate an ordered list of textile inputs" do
      generated_html = custom_rich_text_area(@resource,"simple_ds",[:title],:datastream=>false)
      generated_html.should have_tag "ol[rel=title]" do
        with_tag "li#title_0-container.custom-textile-container.field" do
          without_tag "a.destructive.field"
          with_tag "div#title_0-text.textile-text.text", "title1"
          with_tag "input#title_0.textile-edit.edit" do
            with_tag "[value=?]", "title1"
            with_tag "[name=?]", "asset[simple_ds][title][0]"
            with_tag "[data-datastream-name=?]", "simple_ds"
            with_tag "[load-from-datastream=?]", "false"
            with_tag "[rel=?]", "title"
          end
        end
        with_tag "li#title_1-container.custom-textile-container.field" do
          with_tag "a.destructive.field"
          with_tag "div#title_1-text.textile-text.text", "title2"
          with_tag "input#title_1.textile-edit.edit" do
            with_tag "[value=?]", "title2"
            with_tag "[name=?]", "asset[simple_ds][title][1]"
            with_tag "[data-datastream-name=?]", "simple_ds"
            with_tag "[load-from-datastream=?]", "false"
            with_tag "[rel=?]", "title"
          end
        end
      end      
    end   
    it "should render an empty control if the field has no values" do
      generated_html = custom_rich_text_area(@resource,"empty_ds","something",:datastream=>false)      
      generated_html.should have_tag "li#something_0-container.custom-textile-container" do
        with_tag "#something_0-text.textile-text.text", ""
      end
    end
    it "should limit to single-value output with no ordered list if :multiple=>false" do
      generated_html = custom_rich_text_area(@resource,"simple_ds",[:title],:datastream=>false, :multiple=>false)
      #logger.debug("#{generated_html}")
      generated_html.should_not have_tag "ol"
      generated_html.should_not have_tag "li"
      generated_html.should have_tag "span#title-container.custom-textile-container.field" do
        with_tag "div#title-text.textile-text.text", "title1"
        with_tag "input#title.textile-edit.edit[value=title1]" do
          with_tag "[name=?]", "asset[simple_ds][title][0]"
          with_tag "[value=?]", "title1"
        end
      end
    end
    it "should generate an ordered list with content of the first datastream as input for textile" do
      generated_html = custom_rich_text_area(@resource, "simple_datastream", "ds_id", :datastream=>true)      
      generated_html.should have_tag "li#simple_datastream-container.custom-textile-container.field"do
        with_tag "div#simple_datastream-text.textile-text.text", "content of the datastream"
        with_tag "#simple_datastream.textile-edit.edit" do
          with_tag "[value=?]", "content of the datastream"
          with_tag "[name=?]","asset[ds_id][simple_datastream]"
          with_tag "[data-datastream-name=?]", "simple_datastream"
          with_tag "[load-from-datastream=?]", "true"
          with_tag "[rel=?]", "simple_datastream"
        end
      end
    end
    it "should render an empty control if the field has no values" do
      @resource .stubs(:content).returns( "" )
      generated_html = custom_rich_text_area(@resource,"empty_ds","something",:datastream=>true)
      #logger.debug("#{generated_html}")
      generated_html.should have_tag "li#empty_ds-container.custom-textile-container" do
        with_tag "#empty_ds-text.textile-text.text", ""
      end
    end
  end

  describe "custom_radio_button" do
    before (:each) do      
      @resource.stubs(:get_values_from_datastream).with("simple_ds", "option_field", "").returns( ["highlight"] )
      @resource.stubs(:pid).returns("_PID_")
    end
    it "should generate a radio button input and checked based on value from the given datastream" do
      generated_html = custom_radio_button(@resource,"simple_ds","option_field", :choices=>"highlight")
      #logger.debug("#{generated_html}")
      generated_html.should have_tag "input.fieldselector[name=?]", "asset[simple_ds][option_field][0][_PID_]" do
        with_tag "[rel=?]", "option_field"
        with_tag "[value=?]", "choices"
        with_tag "[type=?]","radio"        
      end
    end    
  end

  describe "get_collections" do    
    it "should return collection details" do
      #pending "no way to access render partial in rspec so this method cannot be using rspec"
      stubs(:build_lucene_query).returns "some string"
      stubs(:get_search_results).returns "some search result"
      mock_exhibit=mock("exhibit object")
      Exhibit.expects(:load_instance_from_solr).with("_PID_").returns(mock_exhibit)
      query = build_lucene_query("string")
      get_collections("some content_type","model_name")
      #.should_receive(:render).with(hash_including(:partial => "shared/add_collections"))
    end
  end

end