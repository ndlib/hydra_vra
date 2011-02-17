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
