class VraXml < ActiveFedora::NokogiriDatastream
  
  set_terminology do |t|
    t.root(:path=>"vra", :xmlns=>"http://www.vraweb.org/vracore4.htm", :schema=>"http://www.vraweb.org/vracore4.htm http://gort.ucsd.edu/escowles/vracore4/vra-4.0.xsd")

    t.reference_display(:path=>"display")

    t.reference_location(:path=>"location"){
      t.location_local_name(:path=>"name", :attributes=>{:type=>"geographic", :vocab=>"local"} )
      t.location_site_name(:path=>"name", :attributes=>{:type=>"geographic", :vocab=>"TGN"} ) 
    }

    t.reference_title(:path=>"title"){
      t.relation_type(:path=>{:attribute =>"type"})      
    }

    t.reference_subject_term{
      t.subject_authors(:path=>"term", :attribute =>{:type=>"personalName", :vocab=>"local"})
      t.subject_author_names(:path=>"term", :attribute =>{:type=>"personalName", :vocab=>"ICONCLASS"})
    }

    t.reference_subject(:path=>"subject"){
      t.reference_authors(:path=>"term") {
        t.author_refid(:path=>{:attribute => "refid"})
      }
    }

    t.reference_work_type(:path=>"worktype"){
      t.reference_work_type_vocab(:path=>{:attribute =>"vocab"})
      t.reference_work_refid(:path=>{:attribute =>"refid"})
    }

    t.reference_relation(:path=>"relation"){
      t.relation_type(:path=>{:attribute =>"type"})
      t.relation_id(:path=>{:attribute =>"relids"})
    }

    t.reference_rights(:path=>"right"){
      t.rights_type(:path=>{:attribute => "type"})
      t.reference_text(:path=>"text")
    }

    t.reference_measurements(:path=>"measurements"){
      t.measurements_type(:path=>{:attribute =>"type"})
      t.measurements_unit(:path=>{:attribute =>"unit"})
    }

    t.work(:path=>"work"){
      t.work_id(:path=>{:attribute => "id"}, :label => "Vra Id")
      t.ref_id(:path=>{:attribute => "refid"}, :label => "Reference Id")
      t.source(:path=>{:attribute => "source"}, :label => "Source")

      t.agent_set(:path=>"agentSet"){
        t.agent_display(:ref=>[:reference_display])
        t.agent(:path=>"agent"){
          t.name {
          t.name_vocab(:path=>{:attribute =>"vocab"})
          t.name_refid(:path=>{:attribute =>"refid"})
          t.name_type(:path=>{:attribute =>"type"})
          }
          t.dates{
            t.life(:path=>{:attribute =>"life"})
            t.earliestDate
            t.latestDate
          }
          t.culture
          t.agent_role(:path=>"role")
          t.agent_vocab(:path=>{:attribute =>"vocab"})
          t.role_refid(:path=>{:attribute =>"refid"})
        }
      }

      t.culturalContextSet{        
        t.culturalContext{
          t.cultural_vocab(:path=>{:attribute =>"vocab"})
        }        
      }
      t.cultural_tag(:path=>"culturalContextSet", :default_content_path=>"culturalContext")

      t.date_set(:path=>"dateSet"){
        t.date_display(:ref=>[:reference_display])
        t.date(:path=>"date"){
          t.date_type(:path=>{:attribute =>"type"})
          t.earliest_date(:path=>"earliestDate")
          t.latest_date(:path=>"latestDate")
        }
      }

      t.descriptionSet{
        t.description
      }
      t.description_tag(:path=>"descriptionSet", :default_content_path=>"description")

      t.location_set(:path=>"locationSet"){
        t.location_display(:ref=>[:reference_display])
        t.location(:ref=>[:reference_location])        
      }

      t.subject_set(:path=>"subjectSet"){
        t.subject_display(:ref=>[:reference_display])
        t.subject(:path=>"subject"){
          t.subject_term(:ref=>[:reference_subject_term])
        }        
      }

      t.title_set(:path=>"titleSet"){
        t.title_display(:ref=>[:reference_display])
        t.title(:ref=>[:reference_title])
      }

      t.work_type_set(:path=>"worktypeSet"){
        t.work_type_display(:ref=>[:reference_display])
        t.work_type(:ref=>[:reference_work_type])
      }
    }
    t.image(:path=>"image"){

       t.measurement_set(:path=>"measurementsSet"){
        t.measurements(:ref=>[:reference_measurements])
      }

      t.description_set(:path=>"descriptionSet"){
        t.description_display(:ref=>[:reference_display])
        t.description(:path=>"description")
      }

      t.inscription_set(:path=>"inscriptionSet"){
        t.inscription(:path=>"inscription"){
          t.inscription_signature(:path=>"text", :attributes=>{:type=>"signature"} )
          t.inscription_text(:path=>"text", :attributes=>{:type=>"text"} )
        }
      }

      t.location_set(:path=>"locationSet"){
        t.location_display(:ref=>[:reference_display])
        t.location(:ref=>[:reference_location])        
      }

      t.relation_set(:path=>"relationSet"){        
        t.relation(:ref=>[:reference_relation])
      }

      t.rights_set(:path=>"rightsSet"){
        t.rights_display(:path=>"display")
        t.notes(:path=>"notes")
        t.rights(:ref=>[:reference_rights])
      }

      t.title_set(:path=>"titleSet"){
        t.title_display(:ref=>[:reference_display])
        t.title(:ref=>[:reference_title])
      }

      t.work_type_set(:path=>"worktypeSet"){
        t.work_type_display(:ref=>[:reference_display])
        t.work_type(:ref=>[:reference_work_type])
      }
    }

  end

  # Generates an empty Mods Article (used when you call ModsArticle.new without passing in existing xml)
    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |t|
        t.vra(:version=>"3.3", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
           "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
           "xmlns"=>"http://www.vraweb.org/vracore4.htm",
           "xsi:schemaLocation"=>"http://www.vraweb.org/vracore4.htm http://gort.ucsd.edu/escowles/vracore4/vra-4.0.xsd") {
             t.work(:id=>"", :refid=>"", :source=>"") {
               t.agentSet{
                 t.display_
                 t.agent{
                 t.role
                 }
               }

              t.culturalContextSet{
                t.display_
                t.culturalContext
              }

              t.dateSet{
                t.display_
                t.date(:type =>"activity")
              }

              t.descriptionSet{
                t.description
              }

              t.locationSet{
                t.display_
                t.location(:type=>"local")
                t.name(:type=>"geographic", :vocab=>"")
              }

              t.subjectSet{
                t.display_
                t.subject{
                  t.term(:type=>"SubjectName")
                }                
              }

              t.titleSet{
                t.display_
                t.title(:type=>"")
              }

              t.worktypeSet{
                t.display_
                t.worktype(:vocab=>"")
            }
               
          }
          t.image(:id=>"", :refid=>"") {
               t.measurementsSet{
                 t.display_
                   t.measurementsSet(:type=>"resoultion", :unit=>"ppi")
               }

              t.relationSet{
                t.display_
                t.relation(:type =>"")
              }

              t.titleSet{
                t.display
                t.title(:type=>"")
              }

              t.worktypeSet{
                t.display_
                t.worktype(:vocab=>"", :refid=>"")
            }

          }
        }
      end
      return builder.doc
    end    
end
