require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"
require "hydra"

describe EadXml do
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @collection = Collection.new
    @collection.datastreams["descMetadata"].ng_xml = EadXml.collection_template
    @subcollection = Component.new
    @subcollection.datastreams["descMetadata"].ng_xml = EadXml.subcollection_template
    @item = Component.new
    @item.datastreams["descMetadata"].ng_xml = EadXml.item_template
  end
  
  describe "#item" do
    it "should return empty string if no unitid" do
      @item.datastreams["descMetadata"].get_values([:item, :did, :unitid]).should == [""]
    end

    it "should return string present in unitid element" do
      @item.update_indexed_attributes({[:item, :did, :unitid]=>{0=>"87478"}})
      @item.datastreams["descMetadata"].get_values([:item, :did, :unitid]).should == ["87478"]
    end

    it "should return empty string if no attribute value of person element" do
      @item.datastreams["descMetadata"].get_values([:item, :did, :origination, :persname, :persname_normal]).should == [""]
    end

    it "should return attribute value of person element" do
      @item.update_indexed_attributes({[:item, :did, :origination, :persname, :persname_normal]=>{0=>"John Smith"}})
      @item.datastreams["descMetadata"].get_values([:item, :did, :origination, :persname, :persname_normal]).should == ["John Smith"]
    end

    it "should return empty string if no value person element" do
      @item.datastreams["descMetadata"].get_values([:item, :did, :origination, :persname]).should == [""]
    end

    it "should return string in person element" do
      @item.update_indexed_attributes({[:item, :did, :origination, :persname]=>{0=>"Smith, John"}})
      @item.datastreams["descMetadata"].get_values([:item, :did, :origination, :persname]).should == ["Smith, John"]
    end

    it "should return empty string if no unittitle" do
      @item.datastreams["descMetadata"].get_values([:item, :did, :unittitle]).should == [""]
    end

    it "should return string present in unittitle element" do
      @item.update_indexed_attributes({[:item, :did, :unittitle]=>{0=>"One Dollar"}})
      @item.datastreams["descMetadata"].get_values([:item, :did, :unittitle]).should == ["One Dollar"]
    end

    it "should return empty string if no attribute value for unittitle" do
      @item.datastreams["descMetadata"].get_values([:item, :did, :unittitle, :unittitle_label]).should == [""]
    end

    it "should return string containing attribute value for unittile" do
      @item.update_indexed_attributes({[:item, :did, :unittitle, :unittitle_label] =>{0=>"One Dollar"}})
      @item.datastreams["descMetadata"].get_values([:item, :did, :unittitle, :unittitle_label]).should == ["One Dollar"]
    end

    it "should return empty string if no num" do
      @item.datastreams["descMetadata"].get_values([:item, :did, :unittitle, :num]).should == [""]
    end

    it "should return string present in num element" do
      @item.update_indexed_attributes({[:item, :did, :unittitle, :num]=>{0=>"99987478"}})
      @item.datastreams["descMetadata"].get_values([:item, :did, :unittitle, :num]).should == ["99987478"]
    end

    it "should return empty string if no dimensions" do
      @item.datastreams["descMetadata"].get_values([:item, :did, :physdesc, :dimensions]).should == [""]
    end

    it "should return string present in dimensions element" do
      @item.update_indexed_attributes({[:item, :did, :physdesc, :dimensions]=>{0=>"4x6"}})
      @item.datastreams["descMetadata"].get_values([:item, :did, :physdesc, :dimensions]).should == ["4x6"]
    end

    it "should return empty string if no scopecontent" do
      @item.datastreams["descMetadata"].get_values([:item, :scopecontent]).should == [""]
    end

    it "should return string present in scopecontent element" do
      @item.update_indexed_attributes({[:item, :scopecontent]=>{0=>"Description of the object always goes here.........."}})
      @item.datastreams["descMetadata"].get_values([:item, :scopecontent]).should == ["Description of the object always goes here.........."]
    end

    it "should return empty string if no genreform" do
      @item.datastreams["descMetadata"].get_values([:item, :controlaccess, :genreform]).should == [""]
    end

    it "should return string present in genreform element" do
      @item.update_indexed_attributes({[:item, :controlaccess, :genreform]=>{0=>"genreform"}})
      @item.datastreams["descMetadata"].get_values([:item, :controlaccess, :genreform]).should == ["genreform"]
    end

    it "should return empty string if no odd" do
      @item.datastreams["descMetadata"].get_values([:item, :odd]).should == [""]
    end

    it "should return string present in odd element" do
      @item.update_indexed_attributes({[:item, :odd]=>{0=>"the string of odd goes here"}})
      @item.datastreams["descMetadata"].get_values([:item, :odd]).should == ["the string of odd goes here"]
    end

    it "should return empty string if no acqinfo" do
      @item.datastreams["descMetadata"].get_values([:item, :acqinfo]).should == [""]
    end

    it "should return string present in acqinfo element" do
      @item.update_indexed_attributes({[:item, :acqinfo]=>{0=>"Acquisition Info"}})
      @item.datastreams["descMetadata"].get_values([:item, :acqinfo]).should == ["Acquisition Info"]
    end
    
  end

  describe "#subcomponent" do
    it "should return empty string if no unitid" do
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :unitid]).should == [""]
    end

    it "should return string present in unitid element" do
      @subcollection.update_indexed_attributes({[:dsc, :collection, :did, :unitid]=>{0=>"8/7/78"}})
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :unitid]).should == ["8/7/78"]
    end

    it "should return empty string if no attribute value of unitid element" do
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :unitid, :unitid_identifier]).should == [""]
    end

    it "should return attribute value of unitid element" do
      @subcollection.update_indexed_attributes({[:dsc, :collection, :did, :unitid, :unitid_identifier]=>{0=>"8.7.74"}})
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :unitid, :unitid_identifier]).should == ["8.7.74"]
    end

    it "should return empty string if no printer" do
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :origination, :printer]).should == [""]
    end

    it "should return string pesent in printer element" do
      @subcollection.update_indexed_attributes({[:dsc, :collection, :did, :origination, :printer]=>{0=>"XYZ Company"}})
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :origination, :printer]).should == ["XYZ Company"]
    end

    it "should return empty string if no engraver" do
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :origination, :engraver]).should == [""]
    end

    it "should return string present in engraver element" do
      @subcollection.update_indexed_attributes({[:dsc, :collection, :did, :origination, :engraver]=>{0=>"xyz name"}})
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :origination, :engraver]).should == ["xyz name"]
    end

    it "should return empty string if no value for unitdate" do
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :unittitle, :unitdate]).should == [""]
    end

    it "should return string containing value for unitdate" do
      @subcollection.update_indexed_attributes({[:dsc, :collection, :did, :unittitle, :unitdate] =>{0=>"Jan 1, 1800"}})
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :unittitle, :unitdate]).should == ["Jan 1, 1800"]
    end

    it "should return empty string if no geog" do
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :unittitle, :imprint, :geogname]).should == [""]
    end

    it "should return string present in geog element" do
      @subcollection.update_indexed_attributes({[:dsc, :collection, :did, :unittitle, :imprint, :geogname]=>{0=>"INDIA"}})
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :unittitle, :imprint, :geogname]).should == ["INDIA"]
    end

    it "should return empty string if no publisher" do
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :unittitle, :imprint, :publisher]).should == [""]
    end

    it "should return string present in publisher element" do
      @subcollection.update_indexed_attributes({[:dsc, :collection, :did, :unittitle, :imprint, :publisher]=>{0=>"South Bend"}})
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :unittitle, :imprint, :publisher]).should == ["South Bend"]
    end

    it "should return empty array if no unittitle" do
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :unittitle, :unittitle_content]).should == []
    end

    it "should return string present in unittitle element" do
      @subcollection.update_indexed_attributes({[:dsc, :collection, :did, :unittitle, :unittitle_content]=>{0=>"March 1, 1908"}})
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :did, :unittitle, :unittitle_content]).should == ["March 1, 1908"]
    end

    it "should return empty string if no genreform" do
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :controlaccess, :genreform]).should == [""]
    end

    it "should return string present in genreform element" do
      @subcollection.update_indexed_attributes({[:dsc, :collection, :controlaccess, :genreform]=>{0=>"genreform"}})
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :controlaccess, :genreform]).should == ["genreform"]
    end

    it "should return empty string if no odd" do
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :odd]).should == [""]
    end

    it "should return string present in odd element" do
      @subcollection.update_indexed_attributes({[:dsc, :collection, :odd]=>{0=>"the string of odd goes here"}})
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :odd]).should == ["the string of odd goes here"]
    end

    it "should return empty string if no scopecontent" do
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :scopecontent]).should == [""]
    end

    it "should return string present in scopecontent element" do
      @subcollection.update_indexed_attributes({[:dsc, :collection, :scopecontent]=>{0=>"Scope Content"}})
      @subcollection.datastreams["descMetadata"].get_values([:dsc, :collection, :scopecontent]).should == ["Scope Content"]
    end
  end

  describe "#collection" do
    it "should return empty string if no eadid" do
      @collection.datastreams["descMetadata"].get_values([:ead_header, :eadid]).should == [""]
    end

    it "should return string present in eadid element" do
      @collection.update_indexed_attributes({[:ead_header, :eadid]=>{0=>"american_colonial"}})
      @collection.datastreams["descMetadata"].get_values([:ead_header, :eadid]).should == ["american_colonial"]
    end

    it "should return empty string if no value for title element" do
      @collection.datastreams["descMetadata"].get_values([:ead_header, :filedesc, :titlestmt, :titleproper]).should == [""]
    end

    it "should return value of title element" do
      @collection.update_indexed_attributes({[:ead_header, :filedesc, :titlestmt, :titleproper]=>{0=>"Title of the collection"}})
      @collection.datastreams["descMetadata"].get_values([:ead_header, :filedesc, :titlestmt, :titleproper]).should == ["Title of the collection"]
    end

    it "should return empty string if no author" do
      @collection.datastreams["descMetadata"].get_values([:ead_header, :filedesc, :titlestmt, :author]).should == [""]
    end

    it "should return string present in author element" do
      @collection.update_indexed_attributes({[:ead_header, :filedesc, :titlestmt, :author]=>{0=>"John Smith"}})
      @collection.datastreams["descMetadata"].get_values([:ead_header, :filedesc, :titlestmt, :author]).should == ["John Smith"]
    end

    it "should return empty string if no publisher" do
      @collection.datastreams["descMetadata"].get_values([:ead_header, :filedesc, :publicationstmt, :publisher]).should == [""]
    end

    it "should return string present in publisher element" do
      @collection.update_indexed_attributes({[:ead_header, :filedesc, :publicationstmt, :publisher]=>{0=>"xyz name"}})
      @collection.datastreams["descMetadata"].get_values([:ead_header, :filedesc, :publicationstmt, :publisher]).should == ["xyz name"]
    end

    it "should return empty string if no value for addressline" do
      @collection.datastreams["descMetadata"].get_values([:ead_header, :filedesc, :publicationstmt, :address, :addressline]).should == [""]
    end

    it "should return string containing value for addressline" do
      @collection.update_indexed_attributes({[:ead_header, :filedesc, :publicationstmt, :address, :addressline] =>{0=>"South Bend"}})
      @collection.datastreams["descMetadata"].get_values([:ead_header, :filedesc, :publicationstmt, :address, :addressline]).should == ["South Bend"]
    end

    it "should return empty string if no date" do
      @collection.datastreams["descMetadata"].get_values([:ead_header, :filedesc, :publicationstmt, :date]).should == [""]
    end

    it "should return string present in date element" do
      @collection.update_indexed_attributes({[:ead_header, :filedesc, :publicationstmt, :date]=>{0=>"02/16/1900"}})
      @collection.datastreams["descMetadata"].get_values([:ead_header, :filedesc, :publicationstmt, :date]).should == ["02/16/1900"]
    end

    it "should return empty string if no creation" do
      @collection.datastreams["descMetadata"].get_values([:ead_header, :profiledesc, :creation]).should == [""]
    end

    it "should return string present in creation element" do
      @collection.update_indexed_attributes({[:ead_header, :profiledesc, :creation]=>{0=>"NDU"}})
      @collection.datastreams["descMetadata"].get_values([:ead_header, :profiledesc, :creation]).should == ["NDU"]
    end

    it "should return empty string if no creation date" do
      @collection.datastreams["descMetadata"].get_values([:ead_header, :profiledesc, :creation, :date]).should == [""]
    end

    it "should return string present in creation date element" do
      @collection.update_indexed_attributes({[:ead_header, :profiledesc, :creation, :date]=>{0=>"March 1, 1908"}})
      @collection.datastreams["descMetadata"].get_values([:ead_header, :profiledesc, :creation, :date]).should == ["March 1, 1908"]
    end

    it "should return empty array if no langusage" do
      @collection.datastreams["descMetadata"].get_values([:ead_header, :profiledesc, :langusage]).should == []
    end

    it "should return string present in langusage element" do
      @collection.update_indexed_attributes({[:ead_header, :profiledesc, :langusage]=>{0=>"English"}})
      @collection.datastreams["descMetadata"].get_values([:ead_header, :profiledesc, :langusage]).should == ["English"]
    end

    it "should return empty array if no language" do
      @collection.datastreams["descMetadata"].get_values([:ead_header, :profiledesc, :langusage, :language]).should == []
    end

    it "should return string present in language element" do
      @collection.update_indexed_attributes({[:ead_header, :profiledesc, :langusage, :language]=>{0=>"French"}})
      @collection.datastreams["descMetadata"].get_values([:ead_header, :profiledesc, :langusage, :language]).should == ["French"]
    end

    it "should return empty string if no title" do
      @collection.datastreams["descMetadata"].get_values([:frontmatter, :titlepage, :titleproper]).should == [""]
    end

    it "should return string present in title element" do
      @collection.update_indexed_attributes({[:frontmatter, :titlepage, :titleproper]=>{0=>"My Title"}})
      @collection.datastreams["descMetadata"].get_values([:frontmatter, :titlepage, :titleproper]).should == ["My Title"]
    end
    
    it "should return empty string if no unithead" do
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :head]).should == [""]
    end

    it "should return string present in unithead element" do
      @collection.update_indexed_attributes({[:archive_desc, :did, :head]=>{0=>"My header"}})
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :head]).should == ["My header"]
    end

    it "should return empty string if no arrchive_title" do
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :unittitle]).should == [""]
    end

    it "should return string present in archive_title element" do
      @collection.update_indexed_attributes({[:archive_desc, :did, :unittitle]=>{0=>"My Title"}})
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :unittitle]).should == ["My Title"]
    end

    it "should return empty string if no archive_id" do
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :unitid]).should == [""]
    end

    it "should return string present in archive_id element" do
      @collection.update_indexed_attributes({[:archive_desc, :did, :unitid]=>{0=>"My ID"}})
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :unitid]).should == ["My ID"]
    end

    it "should return empty string if no archive_date" do
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :unitdate]).should == [""]
    end

    it "should return string present in archive_date element" do
      @collection.update_indexed_attributes({[:archive_desc, :did, :unitdate]=>{0=>"Date"}})
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :unitdate]).should == ["Date"]
    end

    it "should return empty string if no archive_language" do
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :lang, :language]).should == [""]
    end

    it "should return string present in archive_language element" do
      @collection.update_indexed_attributes({[:archive_desc, :did, :lang, :language]=>{0=>"My Language"}})
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :lang, :language]).should == ["My Language"]
    end
    
    it "should return empty string if no archive_corpname" do
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :repo, :corpname]).should == [""]
    end

    it "should return string present in archive_corpname element" do
      @collection.update_indexed_attributes({[:archive_desc, :did, :repo, :corpname]=>{0=>"NDU"}})
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :repo, :corpname]).should == ["NDU"]
    end

    it "should return empty string if no archive_subarea" do
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :repo, :corpname, :subarea]).should == [""]
    end

    it "should return string present in archive_subarea element" do
      @collection.update_indexed_attributes({[:archive_desc, :did, :repo, :corpname, :subarea]=>{0=>"South Bend"}})
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :repo, :corpname, :subarea]).should == ["South Bend"]
    end

    it "should return empty string if no archive_addressline" do
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :repo, :address, :addressline]).should == [""]
    end

    it "should return string present in archive_addressline element" do
      @collection.update_indexed_attributes({[:archive_desc, :did, :repo, :address, :addressline]=>{0=>"Hesburgh library"}})
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :did, :repo, :address, :addressline]).should == ["Hesburgh library"]
    end

    it "should return empty string if no access_restriction_info" do
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :accessrestrict]).should == [""]
    end

    it "should return string present in access_restriction_info element" do
      @collection.update_indexed_attributes({[:archive_desc, :accessrestrict]=>{0=>"My Access Restriction"}})
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :accessrestrict]).should == ["My Access Restriction"]
    end

    it "should return empty string if no access_restriction_head" do
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :acqinfo, :head]).should == [""]
    end

    it "should return string present in access_restriction_head element" do
      @collection.update_indexed_attributes({[:archive_desc, :acqinfo, :head]=>{0=>"My Access Restriction Head"}})
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :acqinfo, :head]).should == ["My Access Restriction Head"]
    end

    it "should return empty string if no prefercite_info" do
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :prefercite]).should == [""]
    end

    it "should return string present in prefercite_info element" do
      @collection.update_indexed_attributes({[:archive_desc, :prefercite]=>{0=>"Prefercite data"}})
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :prefercite]).should == ["Prefercite data"]
    end

    it "should return empty string if no prefercite_head" do
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :prefercite, :head]).should == [""]
    end

    it "should return string present in prefercite_head element" do
      @collection.update_indexed_attributes({[:archive_desc, :prefercite, :head]=>{0=>"Prefercite head"}})
      @collection.datastreams["descMetadata"].get_values([:archive_desc, :prefercite, :head]).should == ["Prefercite head"]
    end
  end

  describe "#item_template" do
    it "should return an empty xml document for item" do
      EadXml.image_template.to_xml.should == "<daoloc href=\"\"/>"
    end
  end

  describe "#item_template" do
    it "should return an empty xml document for item" do
      expected_result = XmlSimple.xml_in("<c02 xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"urn:isbn:1-931666-00-8\">\n  <did>\n    <unitid/>\n    <origination>\n      <persname role=\"signer\" normal=\"\"/>\n    </origination>\n    <unittitle label=\"\">\n      <num type=\"serial\"/>\n    </unittitle>\n    <physdesc>\n      <dimensions/>\n    </physdesc>\n  </did>\n  <scopecontent/>\n  <odd/>\n  <controlaccess>\n    <genreform/>\n  </controlaccess>\n  <acqinfo/>\n  <daogrp>\n    <daoloc href=\"\"/>\n  </daogrp>\n</c02>")
      result = EadXml.item_template.to_xml
      XmlSimple.xml_in(result).should == expected_result
    end
  end

  describe "#subcollection_template" do
    it "should return an empty xml document for subcollection" do
      expected_result = XmlSimple.xml_in("<dsc xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"urn:isbn:1-931666-00-8\">\n  <head/>\n  <c01 level=\"item\">\n    <did>\n      <unitid identifier=\"\"/>\n      <origination>\n        <persname role=\"printer\"/>\n        <persname role=\"engraver\"/>\n      </origination>\n      <unittitle>\n        <unitdate era=\"ce\" calendar=\"gregorian\"/>\n        <imprint>\n          <geogname/>\n          <publisher/>\n        </imprint>\n      </unittitle>\n      <physdesc/>\n    </did>\n    <scopecontent/>\n    <odd/>\n    <controlaccess>\n      <genreform/>\n    </controlaccess>\n  </c01>\n</dsc>")
      result = EadXml.subcollection_template.to_xml
      XmlSimple.xml_in(result).should == expected_result
    end
  end

  describe "#collection_template" do
    it "should return an empty xml document for collection" do
      expected_result = XmlSimple.xml_in("<?xml version=\"1.0\"?>\n<ead xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"urn:isbn:1-931666-00-8\">\n  <eadheader repositoryencoding=\"iso15511\" scriptencoding=\"iso15924\" audience=\"internal\" dateencoding=\"iso8601\" relatedencoding=\"MARC21\" findaidstatus=\"edited-full-draft\" countryencoding=\"iso3166-1\" id=\"a0\" langencoding=\"iso639-2b\">\n    <eadid encodinganalog=\"856\" publicid=\"???\" countrycode=\"US\" mainagencycode=\"inndhl\"/>\n    <filedesc>\n      <titlestmt>\n        <titleproper type=\"filing\"/>\n        <author/>\n      </titlestmt>\n      <publicationstmt>\n        <publisher/>\n        <address>\n          <addressline/>\n        </address>\n        <date era=\"ce\" calendar=\"gregorian\"/>\n      </publicationstmt>\n    </filedesc>\n    <profiledesc>\n      <creation>\n        <date/>\n      </creation>\n      <languages>\n        <language encodinganalog=\"546\" langcode=\"eng\"/>\n      </languages>\n    </profiledesc>\n  </eadheader>\n  <frontmatter>\n    <titlepage>\n      <titleproper/>\n    </titlepage>\n  </frontmatter>\n  <archdesc type=\"register\" level=\"collection\" relatedencoding=\"MARC21\">\n    <did>\n      <head/>\n      <unittitle encodinganalog=\"245$a\" label=\"Title:\"/>\n      <unitid encodinganalog=\"590\" repositorycode=\"inndhl\" countrycode=\"US\"/>\n      <unitdate type=\"bulk\" normal=\"1700/1800\"/>\n      <langmaterial label=\"Language:\">\n        <language/>\n      </langmaterial>\n      <repository encodinganalog=\"852\" label=\"Repository:\">\n        <corpname>\n          <subarea/>\n        </corpname>\n        <address>\n          <addressline/>\n        </address>\n      </repository>\n    </did>\n    <accessrestrict encodinganalog=\"506\">\n      <head/>\n    </accessrestrict>\n    <acqinfo encodinganalog=\"583\">\n      <head/>\n    </acqinfo>\n    <prefercite encodinganalog=\"524\">\n      <head/>\n    </prefercite>\n  </archdesc>\n</ead>\n")
      result = EadXml.collection_template.to_xml
      XmlSimple.xml_in(result).should == expected_result
    end
  end
  
end
