# You can configure hydra exhibit plugin from here.
#
#

HydraExhibit.configure(:shared) do |config|

  config[:excerpt_size]=150

  config[:namespace]="RBSC-CURRENCY"

 # solr fields that will be treated as facets by the blacklight application
  #   The ordering of the field names is the order of the display
  config[:ckeditor_facet] = {
    :field_names => [
      "active_fedora_model_s"
      ],
    :labels => {
        "active_fedora_model_s" => "Description"
    },
    :limits=> {nil=>10}
  }

  config[:descriptions_index_fields] = {
    :field_names => [
        "title_t"
      ],
    :labels => {
      "title_t" =>"Title"
    }
  }


end