class VraXml < ActiveFedora::NokogiriDatastream
  
  set_terminology do |t|
    t.root(:path=>"vra", :xmlns=>"http://www.vraweb.org/vracore4.htm", :schema=>"http://www.vraweb.org/vracore4.htm http://gort.ucsd.edu/escowles/vracore4/vra-4.0.xsd")

    t.reference_display(:path=>"display")

    t.reference_location(:path=>"location"){
      t.location_local_name(:path=>"name", :attributes=>{:type=>"geographic", :vocab=>"local"} )
      t.location_site_name(:path=>"name", :attributes=>{:type=>"geographic", :vocab=>"TGN"} ) #Not sure how these work?????

    }

    t.reference_subject_term(:path=>"term") {
      t.subject_type(:path=>{:attribute =>"type"})
      t.location_vocab(:path=>{:attribute =>"vocab"})
      t.location_refid(:path=>{:attribute =>"refid"})
    }

    t.work(:path=>"work"){
      t.work_id(:path=>{:attribute => "id"}, :label => "Vra Id")
      t.ref_id(:path=>{:attribute => "refid"}, :label => "Reference Id")
      t.source(:path=>{:attribute => "source"}, :label => "Source")

      t.agent_set(:path=>"agentSet"){
        t.agent_display(:ref=>[:reference_display])
        t.agent(:path=>"agent"){
          t.agent_role(:path=>"role")
          t.agent_vocab(:path=>{:attribute =>"vocab"})
          t.role_refid(:path=>{:attribute =>"refid"})
        }
      }

      t.cultural_context_set(:path=>"culturalContextSet"){        
        t.cultural_context(:path=>"culturalContext"){
          t.cultural_vocab(:path=>{:attribute =>"vocab"})
        }
        t.cultural_context(:path=>"culturalContext"){
          t.cultural_vocab(:path=>{:attribute =>"vocab"})
        }
      }

      t.date_set(:path=>"dateSet"){
        t.date_display(:ref=>[:reference_display])
        t.date(:path=>"date"){
          t.date_type(:path=>{:attribute =>"type"})          
        }
      }

      t.description_set(:path=>"descriptionSet"){
        t.description(:path=>"description")
      }

      t.location_set(:path=>"locationSet"){
        t.location_display(:ref=>[:reference_display])
        t.location(:ref=>[:reference_location])
        t.location(:ref=>[:reference_location])
      }

      t.subject_set(:path=>"subjectSet"){
        t.subject_display(:path=>"display")
        t.subject(:path=>"subject"){
          t.subject_term(:ref=>[:reference_subject_term])
        }
        t.subject(:path=>"subject"){
          t.subject_term(:ref=>[:reference_subject_term])
          t.subject_term(:ref=>[:reference_subject_term])
          t.subject_term(:ref=>[:reference_subject_term])
          t.subject_term(:ref=>[:reference_subject_term])
        }
      }

      t.title_set(:path=>"titleSet"){
        t.title_display(:path=>"display")
        t.title(:path=>"title"){
          t.title_type(:path=>{:attribute =>"type"})
          t.title_type(:path=>{:attribute =>"type"})
        }
      }

      t.work_type_set(:path=>"worktypeSet"){
        t.work_type_display(:path=>"display")
        t.work_type(:path=>"worktype"){
          t.work_type_vocab(:path=>{:attribute =>"vocab"})
          t.work_refid(:path=>{:attribute =>"refid"})
        }
      }
    }
    t.image(:path=>"image"){

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
        t.location(:ref=>[:reference_location])
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
                 t.display
                   t.agent{
                   t.role
                   }
               }

              t.culturalContextSet{
                t.culturalContext
              }

              t.dateSet{
                t.display
                t.date(:type =>"activity")
              }

              t.descriptionSet{
                t.description
              }

              t.locationSet{
                t.display
                t.location(:type=>"local")
                t.name(:type=>"geographic", :vocab=>"")
              }

              t.subjectSet{
                t.display
                t.subject{
                  t.term(:type=>"SubjectName")
                }                
              }

              t.titleSet{
                t.display
                t.title(:type=>"")
              }

              t.worktypeSet{
                t.display
                t.worktype(:vocab=>"")
            }
               
          }
          t.image(:id=>"", :refid=>"") {
               t.measurementsSet{
                 t.display
                   t.measurementsSet(:type=>"resoultion", :unit=>"ppi")
               }

              t.relationSet{
                t.display
                t.relation(:type =>"")
              }

              t.titleSet{
                t.display
                t.title(:type=>"")
              }

              t.worktypeSet{
                t.display
                t.worktype(:vocab=>"", :refid=>"")
            }

          }
        }
      end
      return builder.doc
    end    
end
