class EadXml < ActiveFedora::NokogiriDatastream
  set_terminology do |t|
    t.root(:path=>'ead', :xmlns=>"urn:isbn:1-931666-00-8", :schema=>"urn:isbn:1-931666-00-8 http://www.loc.gov/ead/ead.xsd")
    
    t.did_ref(:path=>'did'){
      t.head(:path=>'head')
      t.unittitle(:ref=>[:title_ref])
      t.unitid(:ref=>[:unitid_ref])
      t.unitdate
      t.lang(:ref=>[:lang_ref])
      t.repo(:ref=>[:repo_ref])
      t.origination(:ref=>[:origination_ref])
      t.physdesc(:ref=>[:physdesc_ref])
    }
    t.title_ref(:path=>'unittitle'){
      t.unittitle_content(:path=>'text()')
      t.unittitle_label(:path=>{:attribute=>"label"})
      t.num(:path=>'num')
      t.imprint(:ref=>[:imprint_ref]) #(:path=>'imprint')
#      {
#        t.geogname(:path=>'geogname')
#        t.publisher(:path=>'publisher')
#      }
      t.unitdate(:path=>'unitdate')
    }
    t.imprint_ref(:path=>'imprint'){
      t.geogname
      t.publisher
    }
    t.unitid_ref(:path=>'unitid'){
      t.unitid_identifier(:path=>{:attribute=>"identifier"})
    }
    t.lang_ref(:path=>'langmaterial'){
      t.language
    }
    t.repo_ref(:path=>'repository'){
      t.corpname(:ref=>[:corpname_ref])
      t.address(:ref=>[:address_ref])
    }
    t.corpname_ref(:path=>'corpname'){
      t.subarea
    }
    t.address_ref(:path=>'address'){
      t.addressline
    }
    t.origination_ref(:path=>'origination'){
      t.persname(:path=>'persname'){
        t.persname_normal(:path=>{:attribute=>"normal"})
      }
      t.printer(:path=>'persname', :attributes=>{:role=>"printer"})
      t.engraver(:path=>'persname', :attributes=>{:role=>"engraver"})
    }
    t.physdesc_ref(:path=>'physdesc'){
      t.dimensions
    }
    
    t.collection_ref(:path=>'c01'){
      t.did(:ref=>[:did_ref]){
        t.origination(:ref=>[:origination_ref]){
          t.printer(:path=>'persname', :attributes=>{:role=>"printer"})
          t.engraver(:path=>'persname', :attributes=>{:role=>"engraver"})
        }
      }
      t.scopecontent
      t.odd
      t.controlaccess(:ref=>[:controlaccess_ref])
      t.item(:ref=>[:item_ref])
    }
    t.controlaccess_ref(:path=>'controlaccess'){
      t.genreform
    }
    
    t.item_ref(:path=>'c02'){
      t.did(:ref=>[:did_ref]){
        t.origination(:ref=>[:origination_ref]){
#          t.signer(:path=>'persname', :attribute=>{:role=>"signer"}){
#            t.persname_normal(:path=>{:attribute=>"normal"})
#          }
	t.persname(:path=>'persname', :attribute=>{:role=>"signer"}){
	    t.persname_normal(:path=>{:attribute=>"normal"})
	  }
        }
        t.unittitle(:ref=>[:title_ref]){
          t.unittitle_label(:path=>{:attribute=>"label"})
          t.num(:path=>'num')
        }
      }
      t.scopecontent
      t.odd
      t.controlaccess(:ref=>[:controlaccess_ref])
      t.acqinfo
      t.daogrp(:ref=>[:daogrp_ref])
    }
    t.daogrp_ref(:path=>'daogrp'){
      t.daoloc{
        t.daoloc_href(:path=>{:attribute=>"href"})
      }
    }
    t.acqinfo_ref(:path=>'acqinfo'){
      t.head
      t.p
    }
    t.accessrestrict_ref(:path=>'accessrestrict'){
      t.head
      t.p
    }
    t.prefercite_ref(:path=>'prefercite'){
      t.head
      t.p
    }
    t.dsc_ref(:path=>'dsc'){
      t.head
      t.collection(:ref=>[:collection_ref])
    }
    
    t.archive_desc(:path=>'archdesc', :attributes=>{:level=>"collection"}){
      t.did(:ref=>[:did_ref])
      t.accessrestrict(:ref=>[:accessrestrict_ref])
      t.acqinfo(:ref=>[:acqinfo_ref])
      t.prefercite(:ref=>[:prefercite_ref])
      t.dsc(:ref=>[:dsc_ref])
    }
    t.ead_header(:path=>'eadheader'){
      t.eadid(:path=>'eadid')
      t.filedesc(:path=>'filedesc'){
        t.titlestmt(:path=>'titlestmt'){
          t.titleproper(:path=>'titleproper')
          t.author(:path=>'author')
        }
        t.publicationstmt(:path=>'publicationstmt'){
          t.publisher(:path=>'publisher')
          t.address(:path=>'address'){
            t.addressline
          }
          t.date(:path=>'date')
        }
      }
      t.profiledesc(:path=>'profiledesc'){
        t.creation(:path=>'creation'){
          t.date
        }
        t.langusage(:path=>'langusage'){
          t.language
        }
      }
    }
    t.frontmatter(:path=>'frontmatter'){
      t.titlepage(:path=>'titlepage'){
        t.titleproper
      }
    }
    t.collection(:ref=>[:collection_ref])
    t.item(:ref=>[:item_ref])
    t.dsc(:ref=>[:dsc_ref])
    
  end
  def self.xml_template
      builder = Nokogiri::XML::Builder.new do |t|
        t.ead(:version=>"1.0", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
              "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
              "xmlns"=>"urn:isbn:1-931666-00-8",
              "xsi:schemaLocation"=>"urn:isbn:1-931666-00-8 http://www.loc.gov/ead/ead.xsd"){
              
          t.eadheader(:findaidstatus=>"edited-full-draft", :langencoding=>"iso639-2b", :audience=>"internal", :id=>"a0", :repositoryencoding=>"iso15511", :scriptencoding=>"iso15924", :dateencoding=>"iso8601", :relatedencoding=>"MARC21", :countryencoding=>"iso3166-1"){
            t.eadid(:encodinganalog=>"856", :publicid=>"???", :countrycode=>"US", :mainagencycode=>"inndhl")
            t.filedesc{
              t.titlestmt{
                t.titleproper(:type=>"filing")
                t.author
              }
              t.publicationstmt{
                t.publisher
                t.address{
                  t.addressline
                }
                t.date(:era=>"ce", :calendar=>"gregorian")
              }
            }
            t.profiledesc{
              t.creation{
                t.date
              }
              t.langusage{
                t.language(:langcode=>"eng", :encodinganalog=>"546")
              }
            }
          }
          t.frontmatter{
            t.titlepage{
              t.titleproper
            }
          }
          t.archdesc(:type=>"register", :level=>"collection", :relatedencoding=>"MARC21"){
            t.did{
              t.head
              t.unittitle(:label=>"Title:", :encodinganalog=>"245$a")
              t.unitid(:encodinganalog=>"590", :countrycode=>"US", :repositorycode=>"inndhl")
              t.unitdate(:type=>"bulk", :normal=>"1700/1800")
              t.langmaterial(:label=>"Language:"){
                t.language
              }
              t.repository(:label=>"Repository:", :encodinganalog=>"852"){
                t.corpname{
                  t.subarea
                }
                t.address{
                  t.addressline
                }
              }
            }
            t.accessrestrict(:encodinganalog=>"506"){
              t.head
              t.p
            }
            t.acqinfo(:encodinganalog=>"583"){
              t.head
              t.p
            }
            t.prefercite(:encodinganalog=>"524"){
              t.head
              t.p
            }
            t.dsc{
              t.head
              t.c01(:level=>"item"){
                t.did{
                  t.unitid(:identifier=>"")
                  t.origination{
                    t.persname(:role=>"printer")
                    t.persname(:role=>"engraver")
                  }
                  t.unittitle{
                    t.unitdate(:era=>"ce", :calendar=>"gregorian")
                    t.imprint{
                      t.geogname
                      t.publisher
                    }
                  }
                  t.physdesc
                }
                t.scopecontent{
                  t.p
                }
                t.odd{
                  t.p
                }
                t.controlaccess{
                  t.genreform
                }
                t.c02{
                  t.did{
                    t.unitid
                    t.origination{
                      t.persname(:role=>"signer", :normal=>"")
                    }
                    t.unittitle(:label=>""){
                      t.num(:type=>"serial")
                    }
                    t.physdesc{
                      t.dimensions
                    }
                  }
                  t.scopecontent{
                    t.p
                  }
                  t.odd{
                    t.p
                  }
                  t.controlaccess{
                    t.genreform
                  }
                  t.acqinfo{
                    t.p
                  }
                  t.daogrp{
                  t.daoloc(:href=>"")
                }
              }
            }
          }
        }
      }
    end
    return builder.doc
  end
  def self.collection_template
    builder = Nokogiri::XML::Builder.new do |t|
      t.ead("xmlns:xlink"=>"http://www.w3.org/1999/xlink", "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
              "xmlns"=>"urn:isbn:1-931666-00-8"){
        
        t.eadheader(:findaidstatus=>"edited-full-draft", :langencoding=>"iso639-2b", :audience=>"internal", :id=>"a0", :repositoryencoding=>"iso15511", :scriptencoding=>"iso15924", :dateencoding=>"iso8601", :relatedencoding=>"MARC21", :countryencoding=>"iso3166-1"){
            t.eadid(:encodinganalog=>"856", :publicid=>"???", :countrycode=>"US", :mainagencycode=>"inndhl")
            t.filedesc{
              t.titlestmt{
                t.titleproper(:type=>"filing")
                t.author
              }
              t.publicationstmt{
                t.publisher
                t.address{
                  t.addressline
                }
                t.date(:era=>"ce", :calendar=>"gregorian")
              }
            }
            t.profiledesc{
              t.creation{
                t.date
              }
              t.languages{
                t.language(:langcode=>"eng", :encodinganalog=>"546")
              }
            }
          }
          t.frontmatter{
            t.titlepage{
              t.titleproper
            }
          }
          t.archdesc(:type=>"register", :level=>"collection", :relatedencoding=>"MARC21"){
            t.did{
              t.head
              t.unittitle(:label=>"Title:", :encodinganalog=>"245$a")
              t.unitid(:encodinganalog=>"590", :countrycode=>"US", :repositorycode=>"inndhl")
              t.unitdate(:type=>"bulk", :normal=>"1700/1800")
              t.langmaterial(:label=>"Language:"){
                t.language
              }
              t.repository(:label=>"Repository:", :encodinganalog=>"852"){
                t.corpname{
                  t.subarea
                }
                t.address{
                  t.addressline
                }
              }
            }
            t.accessrestrict(:encodinganalog=>"506"){
              t.head
              t.p
            }
            t.acqinfo(:encodinganalog=>"583"){
              t.head
              t.p
            }
            t.prefercite(:encodinganalog=>"524"){
              t.head
              t.p
            }
        }
      }
    end
    return builder.doc
  end
  def self.subcollection_template
    builder = Nokogiri::XML::Builder.new do |t|
      t.dsc("xmlns:xlink"=>"http://www.w3.org/1999/xlink", "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
              "xmlns"=>"urn:isbn:1-931666-00-8"){
        t.head
        t.c01(:level=>"item"){
          t.did{
            t.unitid(:identifier=>"")
            t.origination{
              t.persname(:role=>"printer")
              t.persname(:role=>"engraver")
            }
            t.unittitle{
              t.unitdate(:era=>"ce", :calendar=>"gregorian")
              t.imprint{
                t.geogname
                t.publisher
              }
            }
            t.physdesc
          }
          t.scopecontent{
            t.p
          }
          t.odd{
            t.p
          }
          t.controlaccess{
            t.genreform
          }
        }
      }
    end
    return builder.doc.root
  end
  def self.image_template
    builder = Nokogiri::XML::Builder.new do |t|
      t.daoloc(:href=>"")
    end
    return builder.doc.root
  end
  def self.item_template
    builder = Nokogiri::XML::Builder.new do |t|
      t.c02("xmlns:xlink"=>"http://www.w3.org/1999/xlink", "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
              "xmlns"=>"urn:isbn:1-931666-00-8"){
        t.did{
          t.unitid
          t.origination{
            t.persname(:role=>"signer", :normal=>"")
          }
          t.unittitle(:label=>""){
            t.num(:type=>"serial")
          }
          t.physdesc{
            t.dimensions
          }
        }
        t.scopecontent{
          t.p
        }
        t.odd{
          t.p
        }
        t.controlaccess{
          t.genreform
        }
        t.acqinfo{
          t.p
        }
        t.daogrp{
          t.daoloc(:href=>"")
        }
      }
    end
    return builder.doc.root
  end
  
  def insert_node(type, opts={})
    case type.to_sym
      when :collection
        node = EadXml.collection_template
        nodeset = self.find_by_terms(:eadheader)
      when :subcollection
        node = EadXml.subcollection_template
        nodeset = self.find_by_terms(:collection)
      when :item
        node = EadXml.item_template
        nodeset = self.find_by_terms(:archive_desc, :dsc, :collection, :item)
      when :image
        node = EadXml.image_template
        nodeset = self.find_by_terms(:collection)
      else
        ActiveFedora.logger.warn("#{type} is not a valid argument for EadXml.insert_node")
        node = nil
        index = nil
    end
    unless nodeset.nil?
      if nodeset.empty?
        self.ng_xml.root.add_child(node)
        index = 0
      else
        nodeset.after(node)
        index = nodeset.length
      end
      self.dirty = true
    end
    return node, index
  end

  # Remove the Image or agent entry identified by @node_type and @index
  def remove_node(node_type, index)
    #TODO: Added code to remove any given node
    case node_type.to_sym
       when :subcollection
        remove_node = self.find_by_terms(:archive_desc, :dsc, :collection)[index.to_i]
      when :item
        remove_node = self.find_by_terms(:archive_desc, :dsc, :collection, :item)[index.to_i]
      when :image
        remove_node = self.find_by_terms(:item, :daogrp, :daoloc, :daoloc_href)[index.to_i]
    end
    unless remove_node.nil?
      puts "Term to delete: #{remove_node.inspect}"
      remove_node.remove
      self.dirty = true
    end
  end
  
  def initialize(attrs={})
    super
    @fields={}
    self.class.from_xml(blob, self)
  end
end
