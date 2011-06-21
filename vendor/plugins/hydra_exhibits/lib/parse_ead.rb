require 'nokogiri'
class ParseEad
  def self.eadparser(filename)
    xml_doc = Nokogiri::XML(File.open(filename))
    collection = Collection.new
    collection.datastreams["descMetadata"].ng_xml = EadXml.fa_collection_template
    xml_doc.search('//ead/eadheader').each do |element|
      element.keys.each do |attrb|
	if(CollectionBean.col_ele.include?"#{element.name}_#{attrb}")
	  collection.update_indexed_attributes({CollectionBean.col_ele["#{element.name}_#{attrb}"]=>{"0"=>element.attributes[attrb]}})
	end
      end
      element.children.each do |l2_element|
        if(l2_element.name.to_s.eql?"eadid")
          collection.update_indexed_attributes({CollectionBean.col_ele[l2_element.name.to_s]=>{"0"=>l2_element.text}})
	  l2_element.keys.each do |attrb|
	    if(CollectionBean.col_ele.include?"#{l2_element.name}_#{attrb}")
	      collection.update_indexed_attributes({CollectionBean.col_ele["#{l2_element.name}_#{attrb}"]=>{"0"=>l2_element.attributes[attrb]}})
	    end
          end
        else
	  parent = l2_element.name.to_s
	  l2_element.children.each do |l3_element|
	    term_ele = "#{parent}_#{l3_element.name.to_s}"
	    if(CollectionBean.col_ele.keys.include?(term_ele))
	      if(CollectionBean.col_ele.keys.include?("#{parent}"))
	        collection.update_indexed_attributes({CollectionBean.col_ele["#{parent}"]=>{"0"=>l2_element.text.sub(l3_element.text,"")}})
	      end
	      collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}"]=>{"0"=>l3_element.text}})
	    end
	    l3_element.keys.each do |attrb|
	      if(CollectionBean.col_ele.include?"#{l2_element.name}_#{l3_element.name}_#{attrb}")
	  	collection.update_indexed_attributes({CollectionBean.col_ele["#{l2_element.name}_#{l3_element.name}_#{attrb}"]=>{"0"=>l3_element.attributes[attrb]}})
	      end
	    end
	    l3_element.children.each do |l4_element|
	      if(CollectionBean.col_ele.keys.include?("#{term_ele}_#{l4_element.name}"))
		if(CollectionBean.col_ele.keys.include?("#{term_ele}"))
	          collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}"]=>{"0"=>l3_element.text.sub(l4_element.text,"")}})
	        end
		collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{l4_element.name}"]=>{"0"=>l4_element.text}})
	      end
	      l4_element.keys.each do |attrb|
		if(CollectionBean.col_ele.include?"#{term_ele}_#{l4_element.name}_#{attrb}")
	  	  collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{l4_element.name}_#{attrb}"]=>{"0"=>l4_element.attributes[attrb]}}) ######
	        end
	      end
	    end
	  end
        end
      end
    end
    xml_doc.search('//ead/frontmatter').each do |element|
      parent = element.name
      element.children.each do |l2_element|
	term_ele = "#{parent}_#{l2_element.name}"
	l2_element.children.each do |l3_element|
	  if(CollectionBean.col_ele.keys.include?("#{term_ele}_#{l3_element.name}"))
	    collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{l3_element.name}"]=>{"0"=>l3_element.text}})
	  end
	end
      end
    end
    xml_doc.search('//ead/archdesc').each do |element|
      parent = element.name
      puts "Element: #{parent}"
      element.keys.each do |attrb|
	if(CollectionBean.col_ele.include?"#{element.name}_#{attrb}")
	  collection.update_indexed_attributes({CollectionBean.col_ele["#{element.name}_#{attrb}"]=>{"0"=>element.attributes[attrb]}})
	end
      end
      element.children.each do |l2_element|
	if(!l2_element.name.eql?"dsc")
	  term_ele = "#{parent}_#{l2_element.name}"
	  if(CollectionBean.col_ele.keys.include?("#{term_ele}"))
            if(!l2_element.name.eql?"text")      
              tv = [:archive_desc, l2_element.name.to_sym]
              pnode = collection.datastreams["descMetadata"].find_by_terms(*tv)[0]
              if(pnode.nil?)
                tv.delete_at(tv.size - 1)
                pnode = collection.datastreams["descMetadata"].find_by_terms(:archive_desc)[0]
                collection.datastreams["descMetadata"].add_child_node(pnode, :simple_node, l2_element.name.to_sym, l2_element.text, l2_element.attributes)
              end
            end
	  end
	  l2_element.keys.each do |attrb|
	    if(CollectionBean.col_ele.include?"#{term_ele}_#{attrb}")
	      collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{attrb}"]=>{"0"=>l2_element.attributes[attrb]}})
	    end
	  end
	  parent_node = nil
	  sibling_node = nil
	  l2_element.children.each_with_index do |l3_element, index|
	    if(CollectionBean.col_ele.keys.include?("#{term_ele}_#{l3_element.name}"))
	      if(CollectionBean.col_ele.keys.include?("#{term_ele}"))
	        collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}"]=>{"0"=>l2_element.text.sub(l3_element.text,"")}})
	      end
	      arg = CollectionBean.col_ele["#{term_ele}_#{l3_element.name}"]
	      arg.delete_at(arg.size - 1)
	      if(!(parent_node.nil?))
		if sibling_node
		  collection.datastreams["descMetadata"].add_previous_sibling_node(sibling_node, :simple_node, l3_element.name.to_sym, l3_element.text, l3_element.attributes)
		else
		  collection.datastreams["descMetadata"].add_child_node(parent_node, :simple_node, l3_element.name.to_sym, l3_element.text, l3_element.attributes)
		end
		arg = CollectionBean.col_ele["#{term_ele}_#{l3_element.name}"]
		arg.delete_at(arg.size - 1)
		parent_node = collection.datastreams["descMetadata"].find_by_terms(*arg)[0]
	      else
		parent_node = collection.datastreams["descMetadata"].find_by_terms(*arg)[0]
		if(parent_node.nil?)
		  arg.delete_at(arg.size - 1)
		  parent_node = collection.datastreams["descMetadata"].find_by_terms(*arg)[0]
		  collection.datastreams["descMetadata"].add_child_node(parent_node, :simple_node, l3_element.parent.name.to_sym, l3_element.parent.text, l3_element.parent.attributes)
		  arg = CollectionBean.col_ele["#{term_ele}_#{l3_element.name}"]
		  arg.delete_at(arg.size - 1)
		  parent_node = collection.datastreams["descMetadata"].find_by_terms(*arg)[0]
		end
		puts "l3_element: #{l3_element.name}"
		collection.datastreams["descMetadata"].add_child_node(parent_node, :simple_node, l3_element.name.to_sym, l3_element.text, l3_element.attributes)
		arg = CollectionBean.col_ele["#{term_ele}_#{l3_element.name}"]
		sibling_node = collection.datastreams["descMetadata"].find_by_terms(*arg)[0]
		arg.delete_at(arg.size - 1)
		parent_node = collection.datastreams["descMetadata"].find_by_terms(*arg)[0]
	      end
	    end
	    l3_element.keys.each do |attrb|
	      if(CollectionBean.col_ele.include?"#{term_ele}_#{l3_element.name}_#{attrb}")
	        collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{l3_element.name}_#{attrb}"]=>{"0"=>l3_element.attributes[attrb]}})
	      end
	    end
	    gparent = nil
	    gsibling = nil
	    l3_element.children.each do |l4_element|
	      if(CollectionBean.col_ele.keys.include?("#{term_ele}_#{l3_element.name}_#{l4_element.name}"))
		tv_l4_element = CollectionBean.col_ele["#{term_ele}_#{l3_element.name}_#{l4_element.name}"]
	        tv_l4_element.delete_at(tv_l4_element.size - 1)
	        if(!(gparent.nil?))
		  if(!gsibling.nil?)
		    collection.datastreams["descMetadata"].add_previous_sibling_node(gsibling, :simple_node, l4_element.name.to_sym, l4_element.text, l4_element.attributes)
		  else
		    collection.datastreams["descMetadata"].add_child_node(gparent, :simple_node, l4_element.name.to_sym, l4_element.text, l4_element.attributes)
		  end
		  tv_l4_element = CollectionBean.col_ele["#{term_ele}_#{l3_element.name}_#{l4_element.name}"]
		  tv_l4_element.delete_at(tv_l4_element.size - 1)
		  gparent = collection.datastreams["descMetadata"].find_by_terms(*tv_l4_element)[0]
	        else
		  gparent = collection.datastreams["descMetadata"].find_by_terms(*tv_l4_element)[0]
		  if(gparent.nil?)
		    tv_l4_element.delete_at(tv_l4_element.size - 1)
		    gparent = collection.datastreams["descMetadata"].find_by_terms(*tv_l4_element)[0]
		    collection.datastreams["descMetadata"].add_child_node(gparent, :simple_node, l3_element.name.to_sym, l3_element.text, l3_element.attributes)
		    tv_l4_element = CollectionBean.col_ele["#{term_ele}_#{l3_element.name}_#{l4_element.name}"]
		    tv_l4_element.delete_at(tv_l4_element.size - 1)
		    gparent = collection.datastreams["descMetadata"].find_by_terms(*tv_l4_element)[0]
		  end
		  collection.datastreams["descMetadata"].add_child_node(gparent, :simple_node, l4_element.name.to_sym, l4_element.text, l4_element.attributes)
		  tv_l4_element = CollectionBean.col_ele["#{term_ele}_#{l3_element.name}_#{l4_element.name}"]
		  gsibling = collection.datastreams["descMetadata"].find_by_terms(*tv_l4_element)[0]
		  tv_l4_element.delete_at(tv_l4_element.size - 1)
		  gparent = collection.datastreams["descMetadata"].find_by_terms(*tv_l4_element)[0]
	        end
		tmp = tv_l4_element|["#{tv_l4_element.last}_content".to_sym]
                collection.update_indexed_attributes({tmp=>{"0"=>l3_element.text.sub(l4_element.text,"")}})
	      end
	      l4_element.keys.each do |attrb|
		if(CollectionBean.col_ele.include?"#{term_ele}_#{l3_element.name}_#{l4_element.name}_#{attrb}")
	  	  collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{l3_element.name}_#{l4_element.name}_#{attrb}"]=>{"0"=>l4_element.attributes[attrb]}})
	        end
	      end
	      l4_element.children.each do |l5_element|
	        if(CollectionBean.col_ele.keys.include?("#{term_ele}_#{l3_element.name}_#{l4_element.name}_#{l5_element.name}"))
		  if(CollectionBean.col_ele.keys.include?("#{term_ele}_#{l3_element.name}_#{l4_element.name}"))
	            collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{l3_element.name}_#{l4_element.name}"]=>{"0"=>l4_element.text.sub(l5_element.text,"")}})
		  end
		  if(!l5_element.name.eql?"text")
                    l5tv = CollectionBean.col_ele["#{term_ele}_#{l3_element.name}_#{l4_element.name}_#{l5_element.name}"]
		    puts l5tv.inspect
              	    l5node = collection.datastreams["descMetadata"].find_by_terms(*l5tv)[0]
		    tv_arr = Array.new
              	    if(l5node.nil?)
                      tv_arr << l5tv.delete_at(l5tv.size - 1)
		      puts l5tv.inspect
                      l5node = collection.datastreams["descMetadata"].find_by_terms(*l5tv)[0]
		      if(l5node.nil?)
                        tv_arr << l5tv.delete_at(l5tv.size - 1)
		        puts l5tv.inspect
                        l5node = collection.datastreams["descMetadata"].find_by_terms(*l5tv)[0]
			if(l5node.nil?)
                          tv_arr << l5tv.delete_at(l5tv.size - 1)
		          puts l5tv.inspect
                          l5node = collection.datastreams["descMetadata"].find_by_terms(*l5tv)[0]
                          collection.datastreams["descMetadata"].add_child_node(l5node, :simple_node, l3_element.name.to_sym, "", l3_element.attributes)
			  l5tv = l5tv|[tv_arr.last]
                          l5node = collection.datastreams["descMetadata"].find_by_terms(*l5tv)[0]
              	        end
                        collection.datastreams["descMetadata"].add_child_node(l5node, :simple_node, l4_element.name.to_sym, l4_element.text, l4_element.attributes)
			l5tv = l5tv|[tv_arr.last]
                        l5node = collection.datastreams["descMetadata"].find_by_terms(*l5tv)[0]
              	      end
                      collection.datastreams["descMetadata"].add_child_node(l5node, :simple_node, l5_element.name.to_sym, l5_element.text, l5_element.attributes)
              	    end
            	  end
	        end
		l5_element.keys.each do |attrb|
		  if(CollectionBean.col_ele.include?"#{term_ele}_#{l3_element.name}_#{l4_element.name}_#{l5_element.name}_#{attrb}")
	  	    collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{l3_element.name}_#{l4_element.name}_#{l5_element.name}_#{attrb}"]=>{"0"=>l5_element.attributes[attrb]}})
	          end
	        end
	      end
	    end
	    if(index == (l3_element.parent.children.size-1))
	      parent_node = nil
	      sibling_node = nil
	    else
	      if(!l3_element.name.eql?"text")
	        parent_node = l3_element.parent
	      end
	    end
	  end
	else
	  l2_element.children.each do |l3_element|
	    if(CollectionBean.col_ele.keys.include?("#{l3_element.name}"))
	      collection.update_indexed_attributes({CollectionBean.col_ele["#{term_ele}_#{l3_element.name}"]=>{"0"=>l3_element.text}})
	    end
	  end
	end
      end
    end
    collection.save
  end
end
