class EadXml < ActiveFedora::NokogiriDatastream
  set_terminology do |t|
    t.root(:path=>'ead', :xmlns=>"urn:isbn:1-931666-00-8", :schema=>"urn:isbn:1-931666-00-8 http://www.loc.gov/ead/ead.xsd")
    
    t.person_ref(:path=>'origination'){
      t.persname
    }
    t.eadid_ref(:path=>'eadheader'){
      t.eadid
    }
    t.physdesc_ref(:path=>'physdesc'){
      t.dimensions
    }
    t.scopecontent_ref(:path=>'scopecontent'){
      t.p(:path=>'p')
    }
    t.controlaccess_ref(:path=>'controlaccess'){
      t.genreform
    }
    t.acqinfo_ref(:path=>'acqinfo'){
      t.p(:path=>'p')
    }
    t.odd_ref(:path=>'odd'){
      t.p(:path=>'p')
    }
    t.daogrp_ref(:path=>'daogrp'){
      t.daoloc{
        t.daoloc_href(:path=>{:attribute=>"href"})
      }
    }
    t.title_ref(:path=>'unittitle'){
      t.num(:path=>'num')
    }
    t.id_ref(:path=>'unitid')

    t.archive_desc(:path=>'archdesc', :attributes=>{:level=>"collection"}){
      t.dsc(:path=>'dsc'){
        t.c01(:path=>'c01'){
          t.c02(:path=>'c02'){
          	t.did(:path=>'did'){
          	  t.origination(:ref=>[:person_ref]){
          	    t.persname(:path=>'persname', :attributes=>{:role=>"signer"})
          	  }
          	  t.physdesc(:ref=>[:physdesc_ref])
          	  t.unittitle(:ref=>[:title_ref]){
                t.num(:ref=>[:num])
              }
          	  t.unitid(:ref=>[:id_ref])
          	}
          	t.scopecontent(:ref=>[:scopecontent_ref])
            t.odd(:ref=>[:odd_ref])
          	t.controlaccess(:ref=>[:controlaccess_ref])
          	t.acqinfo(:ref=>[:acqinfo_ref])
          	t.daogrp(:ref=>[:daogrp_ref])
          }
        }
      }
    }
    t.ead_header(:ref => [:eadid_ref])

  end
  def self.xml_template
      builder = Nokogiri::XML::Builder.new do |t|
          t.ead(:version=>"1.0", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
              "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
              "xmlns"=>"urn:isbn:1-931666-00-8",
              "xsi:schemaLocation"=>"urn:isbn:1-931666-00-8 http://www.loc.gov/ead/ead.xsd"){
              
              t.eadheader{
                t.eadid
                t.filedesc{
                  t.titlestmt{
                    t.titleproper
                    t.author
                  }
                  t.publicationstmt{
                    t.publisher
                    t.address{
                      t.addressline
                    }
                  }
                }
                t.profiledesc{
                  t.creation{
                    t.date
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
              t.archdesc(:level=>"collection"){
                t.did{
                  t.head
                  t.unittitle
                  t.unitid
                  t.unitdate
                  t.langmaterial{
                    t.language
                  }
                  t.repository{
                    t.corpname{
                      t.subarea
                    }
                    t.address{
                      t.addresslin
                    }
                  }
                }
                t.accessrestrict{
                  t.head
                  t.p
                }
                t.acqinfo{
                  t.head
                  t.p
                }
                t.prefercite{
                  t.head
                  t.p
                }
                t.dsc{
                  t.head
                  t.c01(:level=>"item"){
                    t.did{
                      t.unitid
                      t.origination{
                        t.persname
                      }
                      t.unittitle{
                        t.imprint{
                          t.geogname
                          t.publisher
                        }
                        t.unitdate
                      }
                      t.physdesc
                    }
                    t.scopecontent{
                      t.p
                    }
                    t.controlaccess{
                      t.genreform
                    }
                    t.c02{
                      t.did{
                        t.unitid
                        t.origination{
                          t.persname
                        }
                        t.unittitle{
                          t.num
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
end