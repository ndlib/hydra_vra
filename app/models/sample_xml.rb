class SampleXml < ActiveFedora::NokogiriDatastream       
  
  set_terminology do |t|
    #t.root(:path=>"vra", :xmlns=>"http://www.vraweb.org/vracore4.htm", :schema=>"http://www.vraweb.org/vracore4.htm http://gort.ucsd.edu/escowles/vracore4/vra-4.0.xsd")
    t.root(:path=>"workflow", :xmlns=>""){
      t.object_id(:path=>{:attribute => "objectId"}, :label => "Object Id")      
    }

    # t.process would allow you to leave off
    # the :path, but because we called it something
    # else we have to explicitly give it the path
    t.workflow_step(:path=>"process"){
      t.status(:path=>{:attribute=>"status"})
      t.attempts(:path=>{:attribute=>"attempts"})
    }

    # There is a register-object
    # register-object is a workflow_step which has
    # an attribute of name with value "register-o

    t.register_object(:ref=>[:workflow_step], :attributes=>{:name=>"register_object"})

    t.submit(:ref=>[:workflow_step], :attributes=>{:name=>"submit"})

    t.reader_approval(:ref=>[:workflow_step], :attributes=>{:name=>"reader_approval"})

    t.registrar_approval(:ref=>[:workflow_step], :attributes=>{:name=>"registrar-approval"})

    t.start_accession(:ref=>[:workflow_step], :attributes=>{:name=>"start_accession"})

  end
end
