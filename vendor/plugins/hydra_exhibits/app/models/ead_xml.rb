class EadXml < ActiveFedora::NokogiriDatastream
  set_terminology do |t|
    t.root(:path=>'ead', :xmlns=>"urn:isbn:1-931666-22-9", :schema=>"urn:isbn:1-931666-22-9 http://www.loc.gov/ead/ead.xsd")
    t.did_ref(:path=>'did'){
      t.head(:path=>'head')
      t.unittitle(:path=>'unittitle'){
        t.unittitle_content(:path=>'text()')
        t.unittitle_label(:path=>{:attribute=>"label"})
        t.unittitle_encodinganalog(:path=>{:attribute=>"encodinganalog"})
        t.num(:path=>'num')
        t.imprint(:ref=>[:imprint_ref])
	t.unitdate(:path=>'unitdate')
      }
      t.unitid(:ref=>[:unitid_ref])
      t.unitdate(:path=>"unitdate"){
	t.unitdate_normal(:path=>{:attribute=>"normal"})
	t.unitdate_type(:path=>{:attribute=>"type"})
      }
      t.lang(:ref=>[:lang_ref])
      t.repo(:ref=>[:repo_ref])
      t.origination(:ref=>[:origination_ref])
      t.physdesc(:ref=>[:physdesc_ref])
      t.abstract(:ref=>[:abstract_ref])
    }
    t.title_ref(:path=>'unittitle'){
      t.unittitle_content(:path=>'text()')
      t.unittitle_label(:path=>{:attribute=>"label"})
      t.unittitle_encodinganalog(:path=>{:attribute=>"encodinganalog"})
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
    t.abstract_ref(:path=>'abstract'){
      t.abstract_content(:path=>'text()')
      t.abstract_label(:path=>{:attribute=>"label"})
      t.abstract_encodinganalog(:path=>{:attribute=>"encodinganalog"})
    }
    t.unitid_ref(:path=>'unitid'){
      t.unitid_identifier(:path=>{:attribute=>"identifier"})
      t.unitid_encodinganalog(:path=>{:attribute=>"encodinganalog"})
      t.unitid_countrycode(:path=>{:attribute=>"countrycode"})
      t.unitid_repositorycode(:path=>{:attribute=>"repositorycode"})
    }
    t.lang_ref(:path=>'langmaterial'){
      t.language
    }
    t.repo_ref(:path=>'repository'){
      t.repository_encodinganalog(:path=>{:attribute=>"encodinganalog"})
      t.corpname{
	t.corpname_content(:path=>'text()')
	t.subarea
      }
      t.address{
	t.addressline
      }
    }
    t.corpname_ref(:path=>'corpname'){
      t.subarea
    }
    t.address_ref(:path=>'address'){
      t.addressline
    }
    t.origination_ref(:path=>'origination'){
      t.origination_label(:path=>{:attribute=>"label"})
      t.persname(:path=>'persname'){
        t.persname_normal(:path=>{:attribute=>"normal"})
        t.persname_encodinganalog(:path=>{:attribute=>"encodinganalog"})
        t.persname_rules(:path=>{:attribute=>"rules"})
      }
      t.printer(:path=>'persname', :attributes=>{:role=>"printer"})
      t.engraver(:path=>'persname', :attributes=>{:role=>"engraver"})
    }
    t.physdesc_ref(:path=>'physdesc'){
      t.dimensions
      t.extent{
	t.extent_encodinganalog(:path=>{:attribute=>"encodinganalog"})
      }
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
      t.daogrp(:ref=>[:daogrp_ref])
    }
    t.controlaccess_ref(:path=>'controlaccess'){
      t.genreform
      t.head
      t.subject{
	t.subject_content(:path=>'text()')
      }
      t.persname{
	t.persname_encodinganalog(:path=>{:attribute=>"encodinganalog"})
	t.persname_role(:path=>{:attribute=>"role"})
	t.persname_source(:path=>{:attribute=>"source"})
      }
      t.corpname{
	t.corpname_source(:path=>{:attribute=>"source"})
      }
    }

    t.component_ref(:path=>'c'){
      t.did(:ref=>[:did_ref]){
        t.origination(:ref=>[:origination_ref]){
          t.persname(:path=>'persname'){
            t.persname_role(:path=>{:attribute=>"role"})
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
      t.acqinfo_encodinganalog(:path=>{:attribute=>"encodinganalog"})
      t.head
      t.p
    }
    t.accessrestrict_ref(:path=>'accessrestrict'){
      t.accessrestrict_encodinganalog(:path=>{:attribute=>"encodinganalog"})
      t.head
      t.p
    }
    t.prefercite_ref(:path=>'prefercite'){
      t.prefercite_encodinganalog(:path=>{:attribute=>"encodinganalog"})
      t.head
      t.p
    }
    t.separatedmaterial_ref(:path=>'separatedmaterial'){
      t.separatedmaterial_encodinganalog(:path=>{:attribute=>"encodinganalog"})
      t.separatedmaterial_content(:path=>'text()')
      t.head
      t.p
    }
    t.relatedmaterial_ref(:path=>'relatedmaterial'){
      t.relatedmaterial_encodinganalog(:path=>{:attribute=>"encodinganalog"})
      t.relatedmaterial_content(:path=>'text()')
      t.head
      t.p
    }
    t.bibliography_ref(:path=>'bibliography'){
      t.bibliography_encodinganalog(:path=>{:attribute=>"encodinganalog"})
      t.bibliography_content(:path=>'text()')
      t.head
      t.bibref{
	t.bibref_content(:path=>'text()')
	t.persname
	t.title{
	  t.emph{
	    t.emph_render(:path=>{:attribute=>"render"})
	  }
	}
      }
    }
    t.dsc_ref(:path=>'dsc'){
      t.head
      t.collection(:ref=>[:collection_ref])
    }
    t.dao_ref(:path=>"dao"){
      t.dao_href(:path=>{:attribute=>"href"})
      t.daodesc(:path=>"daodesc")
    }
    t.archive_desc(:path=>'archdesc'){
      t.archive_desc_type(:path=>{:attribute=>"type"})
      t.archive_desc_level(:path=>{:attribute=>"level"})
      t.archive_desc_relatedencoding(:path=>{:attribute=>"relatedencoding"})

      t.did(:ref=>[:did_ref])
      t.dao(:ref=>[:dao_ref])
      t.bioghist{
	t.bioghist_content(:path=>'text()')
	t.head
      }
      t.arrangement{
	t.arrangement_content(:path=>'text()')
	t.head
      }
      t.scopecontent{
	t.scopecontent_content(:path=>'text()')
	t.head
      }
      t.controlaccess(:ref=>[:controlaccess_ref])
      t.accessrestrict(:ref=>[:accessrestrict_ref])
      t.acqinfo(:ref=>[:acqinfo_ref])
      t.prefercite(:ref=>[:prefercite_ref])
      t.separatedmaterial(:ref=>[:separatedmaterial_ref])
      t.relatedmaterial(:ref=>[:relatedmaterial_ref])
      t.bibliography(:ref=>[:bibliography_ref])
      t.dsc(:ref=>[:dsc_ref])
    }
    t.ead_header(:path=>'eadheader'){
      t.eadheader_findaidstatus(:path=>{:attribute=>"findaidstatus"})
      t.eadheader_langencoding(:path=>{:attribute=>"langencoding"})
      t.eadheader_audience(:path=>{:attribute=>"audience"})
      t.eadheader_repositoryencoding(:path=>{:attribute=>"repositoryencoding"})
      t.eadheader_scriptencoding(:path=>{:attribute=>"scriptencoding"})
      t.eadheader_id(:path=>{:attribute=>"id"})
      t.eadheader_dateencoding(:path=>{:attribute=>"dateencoding"})
      t.eadheader_relatedencoding(:path=>{:attribute=>"relatedencoding"})
      t.eadheader_countryencoding(:path=>{:attribute=>"countryencoding"})

      t.eadid(:path=>'eadid'){
	t.eadid_encodinganalog(:path=>{:attribute=>"encodinganalog"})
	t.eadid_publicid(:path=>{:attribute=>"publicid"})
	t.eadid_countrycode(:path=>{:attribute=>"countrycode"})
	t.eadid_mainagencycode(:path=>{:attribute=>"mainagencycode"})
      }
      t.filedesc(:path=>'filedesc'){
        t.titlestmt(:path=>'titlestmt'){
          t.titleproper(:path=>'titleproper'){
	    t.titleproper_type(:path=>{:attribute=>"type"})
	  }
          t.author(:path=>'author')
        }
        t.publicationstmt(:path=>'publicationstmt'){
	  t.num(:path=>"num"){
	    t.num_type(:path=>{:attribute=>"type"})
	  }
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
        t.languages(:path=>'languages'){
          t.language{
	    t.language_langcode(:path=>{:attribute=>"langcode"})
	    t.language_encodinganalog(:path=>{:attribute=>"encodinganalog"})
	  }
        }
        t.langusage(:path=>'langusage'){
          t.language
        }
      }
    }
    t.frontmatter(:path=>'frontmatter'){
      t.titlepage(:path=>'titlepage'){
        t.titleproper
	t.num
      }
    }
    t.collection(:ref=>[:collection_ref])
    t.item(:ref=>[:item_ref])
    t.dsc(:ref=>[:dsc_ref])
    t.component(:ref=>[:component_ref])
    
  end
  def self.xml_template
      builder = Nokogiri::XML::Builder.new do |t|
        t.ead(:version=>"1.0", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
              "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
              "xmlns"=>"urn:isbn:1-931666-22-9",
              "xsi:schemaLocation"=>"urn:isbn:1-931666-22-9 http://www.loc.gov/ead/ead.xsd"){
             
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
                t.langusage(:langcode=>"eng", :encodinganalog=>"546")
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
              "xmlns"=>"urn:isbn:1-931666-22-9"){
        
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
	      t.langusage{
                t.language
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
	      t.c01(:level=>"item")
	    }
        }
      }
    end
    return builder.doc
  end
  def self.fa_collection_template
    builder = Nokogiri::XML::Builder.new do |t|
      t.ead("xmlns:xlink"=>"http://www.w3.org/1999/xlink", "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
              "xmlns"=>"urn:isbn:1-931666-22-9"){
        
        t.eadheader(:findaidstatus=>"", :langencoding=>"", :audience=>"", :id=>"", :repositoryencoding=>"", :scriptencoding=>"", :dateencoding=>"", :relatedencoding=>"", :countryencoding=>""){
            t.eadid(:encodinganalog=>"", :publicid=>"", :countrycode=>"", :mainagencycode=>"")
            t.filedesc{
              t.titlestmt{
                t.titleproper(:type=>"")
                t.author
              }
              t.publicationstmt{
		t.num(:type=>"")
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
                t.language(:langcode=>"", :encodinganalog=>"")
              }
	      t.langusage{
                t.language
	      }
            }
          }
          t.frontmatter{
            t.titlepage{
              t.titleproper
            }
          }
          t.archdesc(:type=>"", :level=>"", :relatedencoding=>""){
            t.did{
              t.head
              t.unittitle(:label=>"", :encodinganalog=>"")
              t.unitid(:encodinganalog=>"", :countrycode=>"", :repositorycode=>"")
              t.unitdate(:type=>"", :normal=>"")
              t.langmaterial(:label=>"Language:"){
                t.language
              }
              t.repository(:label=>"Repository:", :encodinganalog=>""){
                t.corpname{
                  t.subarea
                }
                t.address{
                  t.addressline
                }
              }
            }
            t.accessrestrict(:encodinganalog=>""){
              t.head
              t.p
            }
            t.acqinfo(:encodinganalog=>""){
              t.head
              t.p
            }
            t.prefercite(:encodinganalog=>""){
              t.head
              t.p
            }
	    t.dsc{
	      t.head
	      t.c
	    }
	  }
      }
    end
    return builder.doc
  end
  def self.subcollection_template
    builder = Nokogiri::XML::Builder.new do |t|
        t.c01(:level=>"item", "xmlns:xlink"=>"http://www.w3.org/1999/xlink", "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
              "xmlns"=>"urn:isbn:1-931666-22-9"){
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
	  t.c02
          t.daogrp{
            t.daoloc(:href=>"")
          }
        }
    end
    return builder.doc.root
  end

  def self.component_template
    builder = Nokogiri::XML::Builder.new do |t|
        t.c(:level=>"", "xmlns:xlink"=>"http://www.w3.org/1999/xlink", "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
              "xmlns"=>"urn:isbn:1-931666-22-9"){
          t.did{
            t.unitid(:identifier=>"")
            t.origination{
              t.persname(:role=>"", :normal=>"")
            }
            t.unittitle(:label=>""){
              t.unitdate(:era=>"ce", :calendar=>"gregorian")
              t.imprint{
                t.geogname
                t.publisher
              }
              t.num(:type=>"")
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
	  t.c
          t.daogrp{
            t.daoloc(:href=>"")
          }
          t.acqinfo{
            t.p
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
              "xmlns"=>"urn:isbn:1-931666-22-9"){
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
      when :component
        node = EadXml.component_template
        nodeset = self.find_by_terms(:archive_desc, :dsc, :component)
      when :collection
        node = EadXml.collection_template
        nodeset = self.find_by_terms(:eadheader)
      when :subcollection
        node = EadXml.subcollection_template
        nodeset = self.find_by_terms(:ead, :archive_desc, :dsc, :collection)
      when :item
        node = EadXml.item_template
        nodeset = self.find_by_terms(:archive_desc, :dsc, :collection, :item)
      when :subcol_image
        node = EadXml.image_template
        nodeset = self.find_by_terms(:collection, :daogrp, :daoloc)
      when :image
        node = EadXml.image_template
        nodeset = self.find_by_terms(:item, :daogrp, :daoloc)
      when :col_image
        node = EadXml.image_template
        nodeset = self.find_by_terms(:archive_desc, :dsc, :collection, :item, :daogrp, :daoloc)
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
        remove_node = self.find_by_terms(:item, :daogrp, :daoloc)[index.to_i]
      when :component
        remove_node = self.find_by_terms(:archive_desc, :dsc, :component)[index.to_i]
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
