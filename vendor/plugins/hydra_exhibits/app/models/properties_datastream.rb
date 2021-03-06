class PropertiesDatastream < ActiveFedora::MetadataDatastream

  def self.from_xml(tmpl, node) # :nodoc:
    from_xml_xpath(tmpl,node,"./foxml:datastreamVersion[last()]/foxml:xmlContent/fields/node()")
  end

  def self.from_xml_xpath(tmpl, node, xpath)
    node.xpath(xpath).each do |f|
      unless f.name.to_sym == :text #ignore text node of parent
        tmpl.field(f.name, :string) if tmpl.fields[f.name.to_sym].nil?
        tmpl.send("#{f.name}_append", f.text)
      end
    end
    tmpl.send(:dirty=, false)
    tmpl
  end

  #Just return hash of field name mapped to values array
  def values
    values = {}
    fields.each do |field|
      #since implementing a hash assume only one field value, do not return if value array is empty
      values << {field.first, field.second[:values].first} unless field.second[:values].empty?
    end
    values
  end

  #Update only values passed in 
  #Expects a hash of key value pairs
  def update_values (hash={})
    hash.each_pair do |key, value|
      field(key, :string) if fields[key.to_sym].nil?
      send("#{key}_values=", value)
    end      
  end

  #override so that just gets value from Fedora since no way to detect field values in solr because do not know which fields to detect as field names
  #are dynamic
  def from_solr(solr_doc)
    #this will not work from solr since fields cannot be known ahead of time for redirect to get from Fedora and then parse the xml
    node = Nokogiri::XML::Document.parse(self.content)
    self.class.from_xml_xpath(self,node,"fields/node()")
  end
end
