class PropertiesDatastream < ActiveFedora::MetadataDatastream

  def self.from_xml(tmpl, node) # :nodoc:
    node.xpath("./foxml:datastreamVersion[last()]/foxml:xmlContent/fields/node()").each do |f|
      tmpl.field(f.name, :string) if tmpl.fields[f.name.to_sym].nil?
      tmpl.send("#{f.name}_append", f.text)
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
end
