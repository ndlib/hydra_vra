 (function($) {

   $(document).ready(function() {

      // Setup the ajax indicator
     $('body').append('<div id="ajaxBusy"><p><img src="/images/ajax-loader.gif"></p></div>');

     $('#ajaxBusy').css({
        display:"none",
        width:"100px",
        height: "100px",
        position: "fixed",
        top: "50%",
        left: "50%",
        //background:"url(/images/ajax-loader.gif) no-repeat center #ffff",
        textAlign:"center",
        padding:"10px",
        font:"normal 16px Tahoma, Geneva, sans-serif",
        border:"1px solid #666",
        marginLeft: "-50px",
        marginTop: "-50px",
        overflow: "auto"
     });

     /*shows the loading div every time we have an Ajax call*/
     $(document).ajaxStart(function(){
        $('#ajaxBusy').show();
     }).ajaxStop(function(){
     $('#ajaxBusy').hide();});       

     $('input.update_embedded_search').bind('click',function(){
       var url = $("input#update_embedded_search").first().attr("value")       
       var params =  "q="+$("input#q").first().attr("value")+"&search_field"+$("select#search_field").first().attr("value")     
       var showDiv=$("div.highlighted_search")
       var perviousNode=$("div.highlighted_search").first();

       $.ajax({
         type: "POST",
         url: url,
         dataType: "html",
         data: params,
         success: function(data){
           $(showDiv).last().after(data);
           $(perviousNode).remove();
           $inserted = $(showDiv).last();
         },

         /*(msg){
     		$.noticeAdd({
             inEffect:               {opacity: 'show'},      // in effect
             inEffectDuration:       600,                    // in effect duration in milliseconds
             stayTime:               6000,                   // time in milliseconds before the item has to disappear
             text:                   "highlighted added are " +msg.updated[0].sub_collection_highlighted ,   // content of the item
             stay:                   true,                  // should the notice item stay or not?
             type:                   'notice'                // could also be error, success
            });
         },*/
         error: function(xhr, textStatus, errorThrown){
     		$.noticeAdd({
             inEffect:               {opacity: 'show'},      // in effect
             inEffectDuration:       600,                    // in effect duration in milliseconds
             stayTime:               6000,                   // time in milliseconds before the item has to disappear
             text:                   'Your changes failed'+ xhr.statusText + ': '+ xhr.responseText,
             stay:                   true,                  // should the notice item stay or not?
             type:                   'error'                // could also be error, success
            });
         }
       });
      return false;
    });
     
     $('a.addhighlighted').bind('click',function(){
       var selectedSubcollectionItems = new Array();
       $("input.sub_collection:checked").each(function() {selectedSubcollectionItems.push($(this).val());});
       //var $closestForm = $("form#document_metadata").first();
       //var url = $closestForm.attr("action");
       var url = $("input#update_url").first().attr("value")       
       var params =  "highlighted_items="+selectedSubcollectionItems+"&highlighted_action='add'"
       var showDiv=$("div.show_highlighted_div")
       var perviousNode=$("div.show_highlighted_div").first();

       $.ajax({
         type: "PUT",
         url: url,
         dataType: "html",
         data: params,
         success: function(data){
           $(showDiv).last().after(data);
           $(perviousNode).remove();
           $inserted = $(showDiv).last();
         },
         error: function(xhr, textStatus, errorThrown){
     		$.noticeAdd({
             inEffect:               {opacity: 'show'},      // in effect
             inEffectDuration:       600,                    // in effect duration in milliseconds
             stayTime:               6000,                   // time in milliseconds before the item has to disappear
             text:                   'Your changes failed'+ xhr.statusText + ': '+ xhr.responseText,
             stay:                   true,                  // should the notice item stay or not?
             type:                   'error'                // could also be error, success
            });
         }
       });
      return false;
    });

    $('a.destroy_highlighted').bind('click',function(){
      var url = $(this).attr("action");
      var $itemNode = $(this).closest("dd.item_highlighted")
      $.ajax({
         type: "PUT",
         url: url,
         dataType: "html",
         beforeSend: function() {
   			$itemNode.animate({'backgroundColor':'#fb6c6c'},300);
         },
         success: function() {           
           $itemNode.slideUp(300,function() {
             $itemNode.remove();
           });
         }
      });
    });

    $("div.split-button input.button").next().button( {
    text: false,
    icons: { primary: "ui-icon-triangle-1-s" }
    })
    .click(function() {
      var ulelement= $(this).siblings('ul')
      //$('div.split-button ul#add-main-essay-menu')
              ulelement.is(":hidden") ?
        ulelement.show() : ulelement.hide();
      })
    .parent().buttonset();

    $('div.split-button ul').mouseleave(function(){
        $(this).hide();
    });
       
    $('li.essay').live('click',function(){
      var pid =  $(this).attr("pid")
      str=$(this).text()
      $("#re-run-add-main-essay-action").val(jQuery.trim(str));
      var params = "essay_id="+pid
      var url = $("input#exhibit_add_main_essay_url").first().attr("value")
      var wholeDiv=$("div.edit_setting")
      var perviousNode=$(this).closest("div.edit_setting")     
      $.ajax({
         type: "PUT",
         url: url,
         dataType : "html",
         data: params,
         success: function(data){
           $(wholeDiv).last().after(data);
           $(perviousNode).remove();
           $inserted = $(wholeDiv).last();
           /** repeat the whole set in every drop down ajax call to render the select box again on ajax call **/
           $(".editable-container").hydraTextField();
           $("div.split-button input.button").next().button( {
            text: false,
            icons: { primary: "ui-icon-triangle-1-s" }
           })
           .click(function() {
             var ulelement= $(this).siblings('ul')
             ulelement.is(":hidden") ?
             ulelement.show() : ulelement.hide();
           })
           .parent().buttonset();
           $('div.split-button ul').mouseleave(function(){
             $(this).hide();
           });
         },
         error: function(xhr, textStatus, errorThrown){
     			$.noticeAdd({
             inEffect:               {opacity: 'show'},      // in effect
             inEffectDuration:       600,                    // in effect duration in miliseconds
             stayTime:               6000,                   // time in miliseconds before the item has to disappear
             text:                   'Your changes to' + $editNode.attr("rel") + ' could not be saved because of '+ xhr.statusText + ': '+ xhr.responseText,   // content of the item
             stay:                   true,                  // should the notice item stay or not?
             type:                   'error'                // could also be error, succes
            });
         }
      });
    });

    $('li.collections').live('click',function(){      
      var str=$(this).text()
      $("#re-run-add-colection-action").val(jQuery.trim(str));
      var pid =  $(this).attr("pid")
      var params = "collections_id="+pid
      var url = $("input#exhibit_add_collection_url").first().attr("value")
      var wholeDiv=$("div.edit_setting")
      var perviousNode=$(this).closest("div.edit_setting")      
      $.ajax({
         type: "PUT",
         url: url,
         dataType : "html",
         data: params,
         success: function(data){
           $(wholeDiv).last().after(data);
           $(perviousNode).remove();
           $inserted = $(wholeDiv).last();
           // repeat the whole set in every drop down ajax call to render the select box again on ajax call *
           $(".editable-container").hydraTextField();
           $("div.split-button input.button").next().button( {
            text: false,
            icons: { primary: "ui-icon-triangle-1-s" }
           })
           .click(function() {
             var ulelement= $(this).siblings('ul')
             ulelement.is(":hidden") ?
             ulelement.show() : ulelement.hide();
           })
           .parent().buttonset();
           $('div.split-button ul').mouseleave(function(){
             $(this).hide();
           });
         },
         error: function(xhr, textStatus, errorThrown){
     			$.noticeAdd({
             inEffect:               {opacity: 'show'},      // in effect
             inEffectDuration:       600,                    // in effect duration in miliseconds
             stayTime:               6000,                   // time in miliseconds before the item has to disappear
             text:                   'Your changes to' + $editNode.attr("rel") + ' could not be saved because of '+ xhr.statusText + ': '+ xhr.responseText,   // content of the item
             stay:                   true,                  // should the notice item stay or not?
             type:                   'error'                // could also be error, succes
            });
         }
      });
    });

    $('a.remove_collections').live('click',function(){
      var url = $(this).attr("action");
      var dtNode = $('dt.collections')
      var ddNode = $(this).closest("dd.collections")
      var pid =  $(this).attr("pid")
      var params = "collections_id="+pid     
      $.ajax({
         type: "post",
         url: url,
         data: params,
         dataType: "html",
         beforeSend: function() {
   			dtNode.animate({'backgroundColor':'#fb6c6c'},300);
            ddNode.animate({'backgroundColor':'#fb6c6c'},300);
         },
         success: function() {
           dtNode.slideUp(300,function() {
             dtNode.remove();
           });
           ddNode.slideUp(300,function() {
             ddNode.remove();
           });
         }
      });
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

   /* Initialize the element as a Hydra Editable TextField
   */
   $.fn.exhibitTextField = function(settings) {
     var config = {
        selectors : {
          text  : ".editable-text",
          edit  : ".editable-edit"
        },
        listeners : {
          onFinishEdit : jQuery.fn.hydraExhibit.fluidFinishExhibitEditListener          
        },
        defaultViewText: "click to edit"
      };

     if (settings) $.extend(config, settings);

     this.each(function() {
       fluid.inlineEdit(this, config);
     });

     return this;

   };

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
      //var $closestForm =  $editNode.closest("form");
      var name = $editNode.attr("name");

      var pid = $editNode.attr("data-pid");
      var content_type = $editNode.attr("data-content-type");
      var datastream_name = $editNode.attr("data-datastream-name");


      // collect submit parameters.  These should probably be shoved into a data hash instead of a url string...
      // var field_param = $editNode.fieldSerialize();
      var field_selectors = $("input.fieldselector[rel="+$editNode.attr("rel")+"]").fieldSerialize();         

      var params = "?datastream_name="+datastream_name+"&content_type="+content_type+"&essay_id="+pid+"&essay_action=update_essay"

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
     $("a.addval.rich-textarea", this).live("click",function(e) {       
       $.fn.hydraExhibit.insertEssay(this,e);
     });
   };

   $.fn.essayDeleteButton = function(settings) {
     var config = {};
     if (settings) $.extend(config, settings);
     $("a.destroy_essay", this).live("click", function(e) {
       $.fn.hydraExhibit.deleteEssay(this,e);
     });
    //return this;
   };

    $.fn.hydraExhibit = {

/*
     *  hydraMetadata.fluidFinishEditListener
     *  modelChangedListener for Fluid Components
     *  Purpose: Handler for when you're done editing and want values to submit to the app.
     *  Triggers hydraMetadata.saveEdit()
     */
     fluidFinishExhibitEditListener: function(newValue, oldValue, editNode, viewNode) {
       // Only submit if the value has actually changed.
       if (newValue != oldValue) {
         var result = $.fn.hydraExhibit.saveTitle(editNode, newValue);
       }
       return result;
     },

     /*
     *  hydraMetadata.fluidModelChangedListener
     *  modelChangedListener for Fluid Components
     *  Purpose: Handler for ensuring that the undo decorator's actions will be submitted to the app.
     *  Triggers hydraExhibit.saveTitle()
     */
     fluidModelExhibitChangedListener: function(model, oldModel, source) {

       // this was a really hacky way of checking if the model is being changed by the undo decorator
       if (source && source.options.selectors.undoControl) {
         var result = $.fn.hydraMetadata.saveTitle(source.component.edit);
         return result;
       }
     },

     saveTitle: function(editNode) {
       //alert("Exhibit SaveEdit")

       var $editNode = $(".editable-edit").first();
       var $textNode = $(".editable-text").first();
       var name = $editNode.attr("name");
       var essay_id = $editNode.attr("data-pid");
       var contentType = $editNode.attr("data-content-type");
       var datastreamName = $editNode.attr("data-datastream-name");

       var params = "datastream_name="+datastreamName+"&content_type="+contentType+ "&essay_id="+essay_id+ "&essay_title="+ $editNode.val()+"&essay_action=update_essay_title"+"&_method=put"
       var url = $("input#show_essay_url").first().attr("value")

       $.ajax({
         type: "PUT",
         url: url,
         dataType : "json",
         data: params,
         success: function(msg){
     			$.noticeAdd({
             inEffect:               {opacity: 'show'},      // in effect
             inEffectDuration:       600,                    // in effect duration in miliseconds
             stayTime:               6000,                   // time in miliseconds before the item has to disappear
             text:                   "Your edit to "+ msg.updated[0].field_name +" has been saved as "+msg.updated[0].value+" at index "+msg.updated[0].index,   // content of the item
             stay:                   false,                  // should the notice item stay or not?
             type:                   'notice'                // could also be error, succes
            });
         },
         error: function(xhr, textStatus, errorThrown){
     			$.noticeAdd({
             inEffect:               {opacity: 'show'},      // in effect
             inEffectDuration:       600,                    // in effect duration in miliseconds
             stayTime:               6000,                   // time in miliseconds before the item has to disappear
             text:                   'Your changes to' + $editNode.attr("rel") + ' could not be saved because of '+ xhr.statusText + ': '+ xhr.responseText,   // content of the item
             stay:                   true,                  // should the notice item stay or not?
             type:                   'error'                // could also be error, succes
            });
         }
       });
     },

     insertEssay: function(element){
       //alert("insert essay")
       $element = $(element)
       var fieldName = $element.attr("rel");
       var datastreamName = $element.attr('data-datastream-name');
       var contentType = $element.attr('content-type');

       var values_list = $("ol[rel="+fieldName+"]");
       var new_value_index = values_list.children('li').size();
       //var essayName = $("input#essay_title").first().attr("value");
       var params = "?datastream_name="+datastreamName+"&content_type="+contentType//+"&essay_name="+essayName;
       var assetUrl = $("input#show_essay_url").first().attr("value")+params;
       var addDiv = $("div#add-essay-div").first()
       var essayDiv=$("div.essay_div")
       var essayNode=$(element).closest("div.essay_div")

       var $item = jQuery('<li class=\"field_value essay-textarea-container field\" name="asset[' + fieldName + '][' + new_value_index + ']">' +
              '<a href="" class="destructive"><img src="/images/delete.png" border="0" /></a>' +
              '<label>Essay Title</label> <input type="text" name="essay_title" class="editable-edit" value="" /> ' +
               '<div class="textile-text text" id="'+fieldName+'_'+new_value_index+'">click to add Essay content</div></li>');

       $item.appendTo(essayDiv);
       //alert("Essay Title=> "+$("input.editable-edit").val())
       var submitUrl= assetUrl+"&essay_action=insert_essay" +"&format=html"+"&temp_content="+$("div#"+fieldName+"_"+new_value_index).html();

      function submitEditableTextArea(value, settings) {
       //alert("Submit from function")
       var edits = new Object();
       var result = value;
       edits[settings.name] = [value];
        var returned = $.ajax({
         //async: false,
         type: "PUT",
         //indicator : "<img src='/images/ajax-loader.gif'>",
         url: submitUrl+"&essay_title="+ $("input.editable-edit").val(),
         dataType: "html",
         data: edits,
         success: function(data) {
          $(essayDiv).last().after(data);
          $(essayNode).remove();
          $inserted = $(essayDiv).last();
          $("a.destructive", $inserted).essayDeleteButton();
          $(".essay-textarea-container").essayTextareaField();
          $(".custom-editable-container").exhibitTextField();
          $inserted.insertTextareaValue();
          return(result);
         }
       });

      }
      $("div.textile-text", $item).editable(submitEditableTextArea, {
          method    : "PUT",
          //indicator : "<img src='/images/ajax-loader.gif'>",
          loadtext  : $("div#"+fieldName+"_"+new_value_index).html(),
          type      : "ckeditor",
          submit    : "OK",
          cancel    : "Cancel",
          placeholder : "click to edit essay",
          onblur    : "ignore",
          name      : "asset["+new_value_index+"]["+fieldName+"]",
          id        : "field_id",
          height    : "100",          
          ckeditor  : { toolbar:
                        [
                            ['Bold', 'Italic', '-', 'NumberedList', 'BulletedList', '-', 'Link', 'Unlink'],
                            ['UIColor'], ['Source']
                        ]
                      }
       });




       /*$("div.textile-text", $item).editable(testUrl, {
          method    : "PUT",
          indicator : "<img src='/images/ajax-loader.gif'>",
          loadtext  : $("div#"+fieldName+"_"+new_value_index).html(),
          type      : "ckeditor",
          submit    : "OK",
          cancel    : "Cancel",          
          placeholder : "click to edit essay",
          onblur    : "ignore",
          name      : "asset["+new_value_index+"]["+fieldName+"]",
          id        : "field_id",
          height    : "100",
          submitdata : function() {
                     return {essay_title: $("input.editable-edit").val()}
                     },
          callback:  function(value, settings) {
               alert("hiding");
                //$("div.essay_div").first().hide();
          },

          ckeditor  : { toolbar:
                        [
                            ['Bold', 'Italic', '-', 'NumberedList', 'BulletedList', '-', 'Link', 'Unlink'],
                            ['UIColor'], ['Source']
                        ]
                      }
       });*/
     },

     deleteEssay: function(element){
       $element = $(element)
       var $essayNode = $(element).closest(".remove-essay-div")
       var url =$(element).attr("action");
       var parent_pid = $("form#document_metadata").first().attr("data-pid");
       var parent_content_type = $("form#document_metadata").attr("data-content-type");
       var params ="?asset_id="+parent_pid+"&asset_content_type="+parent_content_type;
       url=url+params;
       //alert("URL: "+url +" Closet Node"+$essayNode);
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
     }
    };

 })(jQuery)

