require 'nokogiri'
class ParseEad
  def self.eadparser(filename)
    elements_with_val = Hash.new
    xml_doc = Nokogiri::XML(File.open(filename))
    reader = Nokogiri::XML::Reader(xml_doc.xpath('//ead/eadheader').to_s)
    node_name = ""
    reader.each do |node|
      if(!node.name.to_s.eql?"#text")
        node_name = node.name
      end
      if(!node.value.nil? && (!node.value.to_s.gsub(/\s+/,"").eql?""))
        elements_with_val[node_name] = node.value
      end
    end
    
    elements_with_val.keys.each do |key|
#      puts "#{key} -------------------> #{elements_with_val[key]}"
    end
    collection = Collection.new
    collection.datastreams["descMetadata"].ng_xml = EadXml.fa_collection_template
    xml_doc.search('//ead/eadheader').each do |element|
      element.keys.each do |attrb|
	if(CollectionBean.col_ele.include?"#{element.name}_#{attrb}")
	  collection.update_indexed_attributes({CollectionBean.col_ele["#{element.name}_#{attrb}"]=>{"0"=>element.attributes[attrb]}})
	end
      end
      element.children.each do |child|
        if(child.name.to_s.eql?"eadid")
          collection.update_indexed_attributes({CollectionBean.col_ele[child.name.to_s]=>{"0"=>child.text}})
	  child.keys.each do |attrb|
	    if(CollectionBean.col_ele.include?"#{child.name}_#{attrb}")
	      collection.update_indexed_attributes({CollectionBean.col_ele["#{child.name}_#{attrb}"]=>{"0"=>child.attributes[attrb]}})
	    end
          end
        else
	  parent = child.name.to_s
	  child.children.each do |gchild|
	    term_ele = "#{parent}_#{gchild.name.to_s}"
	    if(CollectionBean.col_ele.keys.include?(term_ele))
	      if(CollectionBean.col_ele.keys.include?("#{parent}"))
	        collection.update_indexed_attributes({CollectionBean.col_ele["#{parent}"]=>{"0"=>child.text.sub(gchild.text,"")}})
	      end
	      collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}"]=>{"0"=>gchild.text}})
	    end
	    gchild.keys.each do |attrb|
	      if(CollectionBean.col_ele.include?"#{child.name}_#{gchild.name}_#{attrb}")
	  	collection.update_indexed_attributes({CollectionBean.col_ele["#{child.name}_#{gchild.name}_#{attrb}"]=>{"0"=>gchild.attributes[attrb]}})
	      end
	    end
	    gchild.children.each do |ggchild|
	      if(CollectionBean.col_ele.keys.include?("#{term_ele}_#{ggchild.name}"))
		if(CollectionBean.col_ele.keys.include?("#{term_ele}"))
	          collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}"]=>{"0"=>gchild.text.sub(ggchild.text,"")}})
	        end
		collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{ggchild.name}"]=>{"0"=>ggchild.text}})
	      end
	      ggchild.keys.each do |attrb|
		if(CollectionBean.col_ele.include?"#{term_ele}_#{ggchild.name}_#{attrb}")
	  	  collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{ggchild.name}_#{attrb}"]=>{"0"=>ggchild.attributes[attrb]}}) ######
	        end
	      end
	    end
	  end
        end
      end
    end
    xml_doc.search('//ead/frontmatter').each do |element|
      parent = element.name
      element.children.each do |child|
	term_ele = "#{parent}_#{child.name}"
	child.children.each do |gchild|
	  if(CollectionBean.col_ele.keys.include?("#{term_ele}_#{gchild.name}"))
	    collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{gchild.name}"]=>{"0"=>gchild.text}})
	  end
	end
      end
    end
    xml_doc.search('//ead/archdesc').each do |element|
      parent = element.name
      element.keys.each do |attrb|
	if(CollectionBean.col_ele.include?"#{element.name}_#{attrb}")
	  collection.update_indexed_attributes({CollectionBean.col_ele["#{element.name}_#{attrb}"]=>{"0"=>element.attributes[attrb]}})
	end
      end
      element.children.each do |child|
	if(!child.name.eql?"dsc")
	  term_ele = "#{parent}_#{child.name}"
	  if(CollectionBean.col_ele.keys.include?("#{term_ele}"))
	    collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}"]=>{"0"=>child.text}})
	  end
	  child.keys.each do |attrb|
	    if(CollectionBean.col_ele.include?"#{term_ele}_#{attrb}")
	      collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{attrb}"]=>{"0"=>child.attributes[attrb]}})
	    end
	  end
	  first_child = nil
	  index = 0
	  if(child.children.size > 1)
	    first_child = child.children[0]
	  end
	  counter = 0
	  child.children.each do |gchild|
	    if(counter > 0)
	      if(first_child.name.eql?(gchild.name))
	        index = index + 1
	      else
		first_child = gchild
	      end
	    end
	    if(CollectionBean.col_ele.keys.include?("#{term_ele}_#{gchild.name}"))
	      if(CollectionBean.col_ele.keys.include?("#{term_ele}"))
	        collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}"]=>{"0"=>child.text.sub(gchild.text,"")}})
	      end
	      puts CollectionBean.col_ele["#{term_ele}_#{gchild.name}"].inspect
	      collection.update_indexed_attributes({CollectionBean.col_ele(index)["#{term_ele}_#{gchild.name}"]=>{"0"=>gchild.text}})
	    end
	    gchild.keys.each do |attrb|
	      if(CollectionBean.col_ele.include?"#{term_ele}_#{gchild.name}_#{attrb}")
	        collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{gchild.name}_#{attrb}"]=>{"0"=>gchild.attributes[attrb]}})
	      end
	    end
	    gchild.children.each do |ggchild|
	      if(CollectionBean.col_ele.keys.include?("#{term_ele}_#{gchild.name}_#{ggchild.name}"))
		if(CollectionBean.col_ele.keys.include?("#{term_ele}_#{gchild.name}"))
		  collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{gchild.name}"]=>{"0"=>gchild.text.sub(ggchild.text,"")}})
		end
	        puts CollectionBean.col_ele["#{term_ele}_#{gchild.name}_#{ggchild.name}"].inspect
	        collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{gchild.name}_#{ggchild.name}"]=>{"0"=>ggchild.text}})
	      end
	      ggchild.keys.each do |attrb|
		if(CollectionBean.col_ele.include?"#{term_ele}_#{gchild.name}_#{ggchild.name}_#{attrb}")
	  	  collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{gchild.name}_#{ggchild.name}_#{attrb}"]=>{"0"=>ggchild.attributes[attrb]}})
	        end
	      end
	      ggchild.children.each do |gggchild|
	        if(CollectionBean.col_ele.keys.include?("#{term_ele}_#{gchild.name}_#{ggchild.name}_#{gggchild.name}"))
		  if(CollectionBean.col_ele.keys.include?("#{term_ele}_#{gchild.name}_#{ggchild.name}"))
	            collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{gchild.name}_#{ggchild.name}"]=>{"0"=>ggchild.text.sub(gggchild.text,"")}})
		  end
	          collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{gchild.name}_#{ggchild.name}_#{gggchild.name}"]=>{"0"=>gggchild.text}})
	        end
		gggchild.keys.each do |attrb|
		  if(CollectionBean.col_ele.include?"#{term_ele}_#{gchild.name}_#{ggchild.name}_#{gggchild.name}_#{attrb}")
	  	    collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{gchild.name}_#{ggchild.name}_#{gggchild.name}_#{attrb}"]=>{"0"=>gggchild.attributes[attrb]}})
	          end
	        end
	      end
	    end
	    counter = counter + 1
	  end
	else
	# The elements under dsc goes here
	end
      end
    end
#    puts collection.datastreams["descMetadata"].to_xml
    collection.save
  end
end
