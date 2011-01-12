 (function($) {

   $(document).ready(function() {     

     $('a.addhighlighted').bind('click',function(){
       var selectedSubcollectionItems = new Array();
       $("input.sub_collection:checked").each(function() {selectedSubcollectionItems.push($(this).val());});
       var $closestForm = $("form#document_metadata").first();
       var url = $closestForm.attr("action");
       var params =  "sub_collection_items="+selectedSubcollectionItems+"&_method='PUT'"
       $.ajax({
         type: "PUT",
         url: url,
         dataType: "json",
         data: params,
         success: function(msg){
     		$.noticeAdd({
             inEffect:               {opacity: 'show'},      // in effect
             inEffectDuration:       600,                    // in effect duration in miliseconds
             stayTime:               6000,                   // time in miliseconds before the item has to disappear
             text:                   "Sub_collection highlighted added are " +msg.updated[0].sub_collection_highlighted ,   // content of the item
             stay:                   true,                  // should the notice item stay or not?
             type:                   'notice'                // could also be error, succes
            });
         },
         error: function(xhr, textStatus, errorThrown){
     		$.noticeAdd({
             inEffect:               {opacity: 'show'},      // in effect
             inEffectDuration:       600,                    // in effect duration in miliseconds
             stayTime:               6000,                   // time in miliseconds before the item has to disappear
             text:                   'Your changes failed'+ xhr.statusText + ': '+ xhr.responseText,
             stay:                   true,                  // should the notice item stay or not?
             type:                   'error'                // could also be error, succes
            });
         }
       });
      return false;
    });

   });
   /*  Initialize the form for inserting new Person (individual) permissions
   *  ex. $("#add-contributor-box").hydraNewContributorForm
   */
   /*var test = "";
   $("div.textile-text", this).live('click', function() {
     test = $("div.textile-text").last()[0].innerHTML;
     alert("Tat->"+test);
   });*/
   $.fn.essayTextareaField = function(settings) {
     //alert("essayTextareaField intialize")
     var config = {
       method    : "PUT",
       indicator : "<img src='/images/ajax-loader.gif'>",
       type    : "ckeditor",
       //type     : "textarea",
       submit    : "OK",
       cancel    : "Cancel",
       placeholder : "click to edit",
       tooltip   : "Click to edit ...",
       onblur    : "ignore",
       id        : "field_id",
       height    : "100",
       ckeditor  : { toolbar:
                        [
                            ['Bold', 'Italic', '-', 'NumberedList', 'BulletedList', '-', 'Link', 'Unlink'],
                            ['UIColor'], ['Source']
                        ]
                     }
     };     

     if (settings) $.extend(config, settings);

     this.each(function() {
      //alert("textile each")
      var $this = $(this);
      var $editNode = $(".textile-edit", this).first();
      var $textNode = $(".textile-text", this).first();
      var $closestForm =  $editNode.closest("form");
      var name = $editNode.attr("name");

      var pid = $editNode.attr("data-pid");
      var content_type = $editNode.attr("data-content-type");
      var datastream_name = $editNode.attr("data-datastream-name");


      // collect submit parameters.  These should probably be shoved into a data hash instead of a url string...
      // var field_param = $editNode.fieldSerialize();
      var field_selectors = $("input.fieldselector[rel="+$editNode.attr("rel")+"]").fieldSerialize();         

      var params = "?datastream_name="+datastream_name+"&content_type="+content_type+"&essay_id="+pid

      //Field Selectors are the only update params to be passed in the url
      //var assetUrl = $closestForm.attr("action") + "&" + field_selectors;
      var assetUrl = $("input#show_essay_url").first().attr("value")+params;
      var submitUrl = $.fn.hydraMetadata.appendFormat(assetUrl, {format: "textile"});

      // These params are all you need to load the value from AssetsController.show
      // Note: the field value must match the field name in solr (minus the solr suffix)
      var load_params = {
        datastream  : $editNode.attr('data-datastream-name'),
        field       : $editNode.attr("rel"),
        field_index : $this.index()
      };
      //alert("Submit url-> "+submitUrl);
      var nodeSpecificSettings = {
        tooltip   : "Click to edit "+$this.attr("id")+" ...",
        name      : name,
        loadurl  : submitUrl //+ "?" + $.param(load_params)
      };
      $textNode.editable(submitUrl, $.extend(nodeSpecificSettings, config));
      $editNode.hide();
     });

     return this;

   };

   $.fn.insertTextareaValue = function(settings) {
     //alert("insertTextareaValue")
     var config = {};
     if (settings) $.extend(config, settings);
     $("a.addval.rich-textarea", this).click(function(e) {
       /*var name = $("input#essay_title").first().attr("value");
       if (name == "" || name.length ==0) {
         alert("Please enter name before adding new essay")
         return false;
       }*/
       $.fn.hydraExhibit.insertEssay(this,e);
     });
   };

   $.fn.essayDeleteButton = function(settings) {
     //alert("Essay Delete")
     var config = {};
     if (settings) $.extend(config, settings);
     //alert("before this function");
     $("a.destroy_essay", this).click(function(e) {
       //alert("lotDeleteButtton live");
       $.fn.hydraExhibit.deleteEssay(this,e);
       //e.preventDefault();
     });
    //return this;
   };

    $.fn.hydraExhibit = {

     deleteEssay: function(element){
       $element = $(element)       
       var $essayNode = $(element).closest(".remove-essay-div")
       var url =$(element).attr("action");
       var parent_pid = $("form#document_metadata").first().attr("data-pid");
       var parent_content_type = $("form#document_metadata").attr("data-content-type");
       var params ="?asset_id="+parent_pid+"&asset_content_type="+parent_content_type;
       url=url+params;
       //alert("URL: "+url +" Closet Nose"+$essayNode);       
       $.ajax({
         type: "DELETE",
         url: url,
         dataType: "html",
         beforeSend: function() {
            //alert("change color")
   			$essayNode.animate({'backgroundColor':'#fb6c6c'},300);
         },
         success: function() {
           //alert("trying to hide")
           $essayNode.slideUp(300,function() {
             $essayNode.remove();
           });
         }
       });
     },

     insertEssay: function(element){      
       $element = $(element)
       var fieldName = $element.attr("rel");
       var datastreamName = $element.attr('data-datastream-name');
       var contentType = $element.attr('content-type');

       var values_list = $("ol[rel="+fieldName+"]");
       var new_value_index = values_list.children('li').size();
       //var essayName = $("input#essay_title").first().attr("value");
       var params = "?datastream_name="+datastreamName+"&content_type="+contentType//+"&essay_name="+essayName;
       var assetUrl = $("input#show_essay_url").first().attr("value")+params;
       var addDiv = $("div#add-essay-div").last()
       var essayDiv=$("div.remove-essay-div").last()

       var $item = jQuery('<label>Essay Name: </label> <input id="essay_title" type="text"/> <li class=\"field_value essay-textarea-container field\" name="asset[' + fieldName + '][' + new_value_index + ']">' +
              '<a href="" class="destructive"><img src="/images/delete.png" border="0" /></a>' +
              '<div class="textile-text text" id="'+fieldName+'_'+new_value_index+'">click to edit</div></li>');

       //$item.appendTo(values_list.last());
       $item.appendTo(essayDiv);

       $("div.textile-text", $item).editable(assetUrl, {
          method    : "PUT",
          indicator : "<img src='/images/ajax-loader.gif'>",
          loadtext  : "",
          type      : "ckeditor",
          submit    : "OK",
          cancel    : "Cancel",
          // tooltip   : "Click to edit #{field_name.gsub(/_/, ' ')}...",
          placeholder : "click to edit",
          onblur    : "ignore",
          name      : "asset["+new_value_index+"]["+fieldName+"]",
          id        : "field_id",
          height    : "100",
          loadurl   : assetUrl +"&format=textile"+"&temp_content="+$("div.textile-text").last()[0].innerHTML+"&test="+test,
          ckeditor  : { toolbar:
                        [
                            ['Bold', 'Italic', '-', 'NumberedList', 'BulletedList', '-', 'Link', 'Unlink'],
                            ['UIColor'], ['Source']
                        ]
                      }
       });
       /*$("div.textile-text", $item).editable(assetUrl+"&format=textile", {
          method    : "PUT",
          indicator : "<img src='/images/ajax-loader.gif'>",
          loadtext  : "",
          type      : "ckeditor",
          submit    : "OK",
          cancel    : "Cancel",
          // tooltip   : "Click to edit #{field_name.gsub(/_/, ' ')}...",
          placeholder : "click to edit",
          onblur    : "ignore",
          name      : "asset["+new_value_index+"]["+fieldName+"]",
          id        : "field_id",
          height    : "100",
          loadurl   : assetUrl +"&temp_content="+$("div.textile-text").last()[0].innerHTML,
          ckeditor  : { toolbar:
                        [
                            ['Bold', 'Italic', '-', 'NumberedList', 'BulletedList', '-', 'Link', 'Unlink'],
                            ['UIColor'], ['Source']
                        ]
                      }
       });*/
     }
        
    };

 })(jQuery)

