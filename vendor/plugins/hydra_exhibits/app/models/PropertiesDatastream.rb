class PropertiesDatastream < ActiveFedora::MetadataDatastream

  def self.from_xml(tmpl, node) # :nodoc:
    node.xpath("./foxml:datastreamVersion[last()]/foxml:xmlContent/fields/node()").each do |f|
      field(f.name, :string) if fields[f.name.to_sym].nil?
      tmpl.send("#{f.name}_append", f.text)
    end
    tmpl.send(:dirty=, false)
    tmpl
  end

  #Just return hash of field name mapped to values array
  def {}
    h = {}
    fields.each do |field|
      h << {field.first, field[:values]}
    end
    h
  end

  def << (hash)
    hash.each_pair do |key, value|
      field(key, :string) if fields[key.to_sym].nil?
      fields << {key=>value}
    end      
  end
end
