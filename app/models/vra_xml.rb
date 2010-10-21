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

  t.reference_subject_term(:path=>"term"){
    t.subject_author_name(:path=>"term", :attribute =>{:type=>"personalName", :vocab=>"local"})
    t.subject_author_name_alt(:path=>"term", :attribute =>{:type=>"personalName", :vocab=>"ICONCLASS"})
    t.subject_term_type(:path=>{:attribute =>"type"})
    t.subject_term_vocab(:path=>{:attribute =>"vocab"})
    t.subject_term_refid(:path=>{:attribute =>"refid"})
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
    #t.description_tag(:path=>"descriptionSet", :default_content_path=>"description")

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
    t.image_id(:path=>{:attribute =>"id"})
    t.image_ref_id(:path=>{:attribute =>"refid"})
    t.image_source(:path=>{:attribute =>"source"})

    t.date_set(:path=>"dateSet"){
      t.date_display(:ref=>[:reference_display])
      t.date(:path=>"date"){
        t.date_type(:path=>{:attribute =>"type"})
      }
    }

    t.measurement_set(:path=>"measurementsSet"){
      t.measurements_display(:ref=>[:reference_display])
      t.measurements(:ref=>[:reference_measurements])
    }

    t.technique_set(:path=>"techniqueSet"){
      t.technique_display(:ref=>[:reference_display])
      t.technique
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
      t.relation(:ref=>[:reference_relation]){
        t.realtion_type(:path=>{:attribute =>"type"})
        t.realtion_refid(:path=>{:attribute =>"refid"})
        t.realtion_source(:path=>{:attribute =>"source"})
      }
    }

    t.rights_set(:path=>"rightsSet"){
      t.rights_display(:path=>"display")
      t.notes(:path=>"notes")
      t.rights(:ref=>[:reference_rights])
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

    t.source_set(:path=>"sourceSet"){
      t.source_display(:ref=>[:reference_display])
      t.source{
        t.name_
        t.refid
        t.ref_type(:path=>{:attribute=>"type"})
      }
    }

    t.work_type_set(:path=>"worktypeSet"){
      t.work_type_display(:ref=>[:reference_display])
      t.work_type(:ref=>[:reference_work_type])
    }
  }

end

  # Generates an empty Vra (used when you call vra.new without passing in existing xml)
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

        t.image(:id=>"", :refid=>"", :source=>"") {

          t.dateSet{
              t.display_
          }

          t.measurementsSet{
            t.display_
            t.measurementsSet(:type=>"resoultion", :unit=>"ppi")
          }

          t.techniqueSet{
            t.display_
            t.technique
          }

          t.descriptionSet{
            t.display_
            t.description
          }

          t.locationSet{
            t.display_
            t.location(:refid=>"")
          }

          t.relationSet{
            t.display_
            t.relation(:type =>"", :ref_id=>"", :source=>"")
          }

          t.rightsSet{
            t.display_
            t.rights
          }

          t.subjectSet{
            t.display_
            t.subject{
              t.term
            }
          }

          t.titleSet{
            t.display_
            t.title(:type=>"")
          }

          t.sourceSet{
            t.display_
            t.source{
              t.name
              t.refid
            }
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

  # Generates a new agent node
  def self.image_template
    builder = Nokogiri::XML::Builder.new do |t|
      t.image(:id=>"", :refid=>"", :source=>"") {

        t.dateSet{
          t.display_
        }

        t.measurementsSet{
          t.display_
          t.measurementsSet(:type=>"resoultion", :unit=>"ppi")
        }

        t.techniqueSet{
          t.display_
          t.technique
        }

        t.descriptionSet{
          t.display_
          t.description
        }

        t.locationSet{
          t.display_
          t.location(:refid=>"")
        }

        t.relationSet{
          t.display_
          t.relation(:type =>"", :ref_id=>"", :source=>"")
        }

        t.rightsSet{
          t.display_
          t.rights
        }

        t.subjectSet{
          t.display_
          t.subject{
            t.term
          }
        }

        t.titleSet{
          t.display_
          t.title(:type=>"")
        }

        t.sourceSet{
          t.display_
          t.source{
            t.name
            t.refid
          }
        }

        t.worktypeSet{
          t.display_
          t.worktype(:vocab=>"", :refid=>"")
        }
      }
    end
    return builder.doc.root
  end

  # Generates a new agent node
  def self.agent_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.agent{
        xml.name(:type=>"personal", :vocab=>"ULAN", :refid=>"")
          xml.dates(:type=>"life"){
          xml.earliestDate
          xml.latestDate
          }
          xml.role
          xml.culture
        }
    end
    return builder.doc.root
  end

  # Inserts a new agent or image (agent) into the vra document
  def insert_node(type, opts={})
    case type.to_sym
      when :agent
        node = VraXml.agent_template
        nodeset = self.find_by_terms(:work,:agent_set, :agent)
      when :image_tag
        node = VraXml.image_template
        nodeset = self.find_by_terms(:image)
      else
        ActiveFedora.logger.warn("#{type} is not a valid argument for VraXml.insert_node")
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

  # Remove the contributor entry identified by @contributor_type and @index
  def remove_node(node_type, index)
    #TODO: Added code to remove any given node
    #self.find_by_terms( {node_type.to_sym => index.to_i} ).first.remove
    #self.dirty = true
  end

end
