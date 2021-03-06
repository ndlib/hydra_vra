 (function($) {

   $(document).ready(function() {

      // Setup the ajax indicator
     $('body').append('<div id="ajaxBusy">Your request is being processed.</div>');

     /*shows the loading div every time we have an Ajax call*/
     /*$(document).ajaxSetup({
        timeout: 3000
     });*/

     $(document).ajaxStart(function(){
        $('#ajaxBusy').show();
     }).ajaxStop(function(){
     $('#ajaxBusy').hide();});

     $('a.thumbnail').lightBox({
         // Configuration related to images
			imageLoading:			'/plugin_assets/hydra_exhibits/images/lightbox-ico-loading.gif',		// (string) Path and the name of the loading icon
			imageBtnPrev:			'/plugin_assets/hydra_exhibits/images/lightbox-btn-prev.gif',			// (string) Path and the name of the prev button image
			imageBtnNext:			'/plugin_assets/hydra_exhibits/images/lightbox-btn-next.gif',			// (string) Path and the name of the next button image
			imageBtnClose:			'/plugin_assets/hydra_exhibits/images/lightbox-btn-close.gif',		// (string) Path and the name of the close btn
			imageBlank:				'/plugin_assets/hydra_exhibits/images/lightbox-blank.gif'			// (string) Path and the name of a blank image (one pixel)
     });

     $.fn.initialize_setting();

     $(".content").hide();
     //toggle the componenet with class msg_body
     //$(".heading").unbind('click').bind('click',function(){
     $(".heading").click(function(){
        $(this).siblings(".intro").toggle()
        $(this).next(".content").slideToggle(300);
        $(this).text($(this).text() == '[Read the complete essay]' ? '[Hide essay]' : '[Read the complete essay]');
     });
      
      $('input:radio[rel*="review"]').change(function(){
       var url = $("input#rev").first().attr("value");
       var params = "rev="+$(this).val();
       var showDiv=$("div.review_comment");
       var perviousNode=$("div.review_comment").first();
      $.ajax({
         type: "POST",
         url: url,
         dataType: "html",
         data: params,
         success: function(data){
           $(showDiv).html(data);
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
     });

     $('input.update_embedded_search').bind('click',function(){
       var url = $("input#update_embedded_search").first().attr("value")       
       var params =  "q="+$("input#q").first().attr("value")+"&search_field"+$("select#search_field").first().attr("value")     
       var showDiv=$("div.featured_search")
       var perviousNode=$("div.featured_search").first();

       $.ajax({
         type: "POST",
         url: url,
         dataType: "html",
         data: params,
         success: function(data){
           $(showDiv).html(data);
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

     $('#toggle_sources').toggle(function(){
       $(this).html('Show Complete Sources').attr('title', 'Reveal the complete listing of sources.');
       $('#complete_sources').slideUp();
     }, function(){
       $(this).html('Hide Complete Sources').attr('title', 'Hide the complete listing of sources.');
       $('#complete_sources').slideDown();
     });

     /*$('input.featured').bind('click',function(){
       var selectedSubexhibitItems = new Array();
       $("input.featured:checked").each(function() {selectedSubexhibitItems.push($(this).val());});       
       var url = $("input#update_url").first().attr("value")       
       var params =  "featured_items="+selectedSubexhibitItems+"&featured_action='add'"
        $.ajax({
         type: "PUT",
         url: url,
         dataType: "html",
         data: params,
         success: function(data){
           $(showDiv).html(data);
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
    });*/
     
     //$('input.addfeatured').unbind('click').bind('click',function(){
       $('input.addfeatured').bind('click',function(){
       var selectedSubexhibitItems = new Array();
       $("input.featured:checked").each(function() {selectedSubexhibitItems.push($(this).val());});       
       var url = $("input#update_url").first().attr("value")       
       var params =  "featured_items="+selectedSubexhibitItems+"&featured_action=add"
       var showDiv=$("div.show_featured_div")
       var perviousNode=$("div.show_featured_div").first();

       $.ajax({
         type: "PUT",
         url: url,
         dataType: "html",
         data: params,
         success: function(data){
           $(showDiv).html(data);
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

    $('a.destroy_featured').live('click',function(){
      var url = $(this).attr("action");
      var $itemNode = $(this).closest("dd.item_featured")
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
      //return false;
    });


       
    $('li.description').live('click',function(){
      var pid =  $(this).attr("pid")
      str=$(this).text()
      $("#re-run-add-main-description-action").val(jQuery.trim(str));
      var params = "description_id="+pid
      var url = $("input#exhibit_add_main_description_url").first().attr("value")
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
           $.fn.initialize_setting();
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
           $.fn.initialize_setting();
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
            ddNode.animate({'backgroundColor':'#fb6c6c'},300);
         },
         success: function() {
           ddNode.slideUp(300,function() {
               ddNode.remove();
           });
           $.fn.initialize_setting();
           $.fn.hydraExhibit.resetSetting();
         }
      });
    });

    $('li.facet').live('click',function(){
       var $closestForm = $(this).closest("form");
       var url = $closestForm.attr("action");
       var index = $("dd.browse_facets ol li").last().attr("index") 
       total = parseInt(index) + 1
       var name = "asset[filters][facets]["+total+"]"
       var params = name + "="+$(this).attr("field_name")+"&_method=put";
       //alert(name)
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
            $.fn.hydraExhibit.resetSetting();
            $.fn.initialize_setting();
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

    $('a.remove_facet').live('click',function(){
       var url = $(this).attr("action");
       var name = "asset[filters][facets]["+$(this).attr("index")+"]"
       var params = name + "="+"&_method=put";
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
            $.fn.initialize_setting();
            $.fn.hydraExhibit.resetSetting();
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
        return false;
    });

    $('dd.display input:radio').live('click',function(){
    //$('dd.display input:radio').die('click').live('click',function(){
      var $closestdd = $(this).closest('dd.display')
      var $closestForm=$closestdd.siblings('input.update_description_display');
      var url = $closestForm.attr("action");
      var name = $(this).attr("datastream")
      var data_pid = $(this).attr("data_pid")
      var params =  name + "="+$(this).attr("value")+"&_method=put";
      //alert("Radio update: "+url)
      //console.log($(this))
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
            $.fn.hydraExhibit.resetSetting();
            $.fn.initialize_setting();
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

   });

   /* Initialize the element as a Hydra exhibit Editable TextField
   */
   $.fn.initialize_setting = function(){
      $("div.split-button input.button").next().button( {
          text: false,
          icons: { primary: "ui-icon-triangle-1-s" }
        })
        //$("div.split-button input.button").next().unbind('click').bind('click',function() {
       .click(function() {
          var ulelement= $(this).siblings('ul')
          ulelement.is(":hidden") ?
            ulelement.show() : ulelement.hide();
          })
        .parent().buttonset();

        $('div.split-button ul').mouseleave(function(){
            $(this).hide();
      });

     $('dd.browse_facets ol li').each(function(){
       index = $(this).attr("index")
       $(this).attr('style', 'text-indent:'+index+'em');;
     });
     return false;
   }

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

   $.fn.descriptionTextareaField = function(settings) {
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
                            ['Bold', 'Italic', '-', 'NumberedList', 'BulletedList', '-', 'Link', 'Unlink', '-', 'linkItem'],
                            ['Cut','Copy','Paste','PasteText','PasteFromWord','-','Print', 'SpellChecker', 'Scayt'],
                            ['UIColor', 'PageBreak'], ['Source'], ['Maximize', 'ShowBlocks','-','About']
                        ]
                     }
     };     

     if (settings) $.extend(config, settings);

     this.each(function() {
      var $this = $(this);
      var $editNode = $(".textile-edit", this).first();
      var $textNode = $(".textile-text", this).first();
      var name = $editNode.attr("name");

      var pid = $editNode.attr("data-pid");
      var content_type = $editNode.attr("data-content-type");
      var datastream_name = $editNode.attr("data-datastream-name");
      var load_datastream = $editNode.attr("load-from-datastream");

      var field_selectors = $("input.fieldselector[rel="+$editNode.attr("rel")+"]").fieldSerialize();         

      var params = "?datastream="+datastream_name+"&load_datastream="+load_datastream+"&name="+name+"&content_type="+content_type+
                    "&description_id="+pid

      var assetUrl = $("input#show_description_url").first().attr("value")+params;
      //var submitUrl = $.fn.hydraMetadata.appendFormat(assetUrl, {format: "textile"});
      var submitUrl = $.fn.hydraMetadata.appendFormat(assetUrl, {format: "html"});

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
        loadurl  : submitUrl + "&" + $.param(load_params)
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
     $("input.addval.rich-textarea", this).live("click",function(e) {       
       $.fn.hydraExhibit.insertDescription(this,e);
     });
   };

   $.fn.descriptionDeleteButton = function(settings) {
     var config = {};
     if (settings) $.extend(config, settings);
     $("a.destroy_description", this).live("click", function(e) {       
       $.fn.hydraExhibit.deleteDescription(this,e);
     });
    //return this;
   };

    $.fn.hydraExhibit = {

    resetSetting: function() {
      var element = $("input#exhibit_refresh_setting_url").first()
      var url = element.attr("value")
      var wholeDiv=$("div.edit_setting")
      var perviousNode=wholeDiv.first()
      //alert("URL=>"+url)
      $.ajax({
         type: "get",
         url: url,
         dataType: "html",
         success: function(data) {
          $(wholeDiv).last().after(data);
          $(perviousNode).remove();
          // repeat the whole set in every drop down ajax call to render the select box again on ajax call
           $(".editable-container").hydraTextField();           
           $.fn.initialize_setting();
         }
      });
    },
        
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
       $editNode = $(editNode);       
       var $textNode = $(".editable-text").first();
       var name = $editNode.attr("name");
       var description_id = $editNode.attr("data-pid");
       var contentType = $editNode.attr("data-content-type");
       var datastreamName = $editNode.attr("data-datastream-name");
       var load_datastream = $editNode.attr("load-from-datastream");

      var field_selectors = $("input.fieldselector[rel="+$editNode.attr("rel")+"]").fieldSerialize();

       var params = "datastream_name="+datastreamName+"&load_datastream="+load_datastream+"&name="+name+"&content_type="+contentType+ "&description_id="+description_id+ "&description_title="+ $editNode.val()+"&_method=put"
       var url = $("input#update_title_url").first().attr("value")
       //$.fn.hydraMetadata.saveDescription(url, params)
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
            $.fn.hydraExhibit.resetSetting();
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

     insertDescription: function(element){
       //alert("insert essay")
       $element = $(element)
       var fieldName = $element.attr("rel");
       var datastreamName = $element.attr('data-datastream-name');
       var contentType = $element.attr('content-type');

       var values_list = $("ol[rel="+fieldName+"]");
       var new_value_index = values_list.children('li').size();       
       var params = "?datastream="+datastreamName+"&content_type="+contentType
       var assetUrl = $("input#add_description_url").first().attr("value")+params;
       var addDiv = $("div#add-description-div").first()
       var essayDiv=$("div.description_div")
       var newEssayDiv=$("div.new-description-div")
       var essayNode=$(element).closest("div.description_div")

       var $item = jQuery('<fieldset id="new_description"><legend>New Description</legend><li class=\"field_value description-textarea-container field\" name="asset[' + datastreamName + '][' + new_value_index + ']">' +
              '<a href="" class="destructive"><img src="/images/delete.png" border="0" /></a>' +
              '<label>Description Title</label> <input type="text" name="description_title" class="editable-edit" value="" /> ' +
               '<div class="textile-text text new" id="'+fieldName+'_'+new_value_index+'">click to add Description content</div></li></fieldset>');

       $item.appendTo(newEssayDiv);

       //alert("Essay Title=> "+$("input.editable-edit").val())
       var submitUrl= assetUrl+"&format=html"+"&temp_content="+$("div#"+fieldName+"_"+new_value_index).html();

      function submitEditableTextArea(value, settings) {
       //alert("Submit from function")
       var edits = new Object();
       var result = value;
       edits[settings.name] = [value];
        var returned = $.ajax({
         //async: false,
         type: "PUT",
         //indicator : "<img src='/images/ajax-loader.gif'>",
         url: submitUrl+"&description_title="+ $("input.editable-edit").val(),
         dataType: "html",
         data: edits,
         success: function(data) {
          $(essayDiv).last().after(data);
          $(essayNode).remove();
          $inserted = $(essayDiv).last();
          $("a.destructive", $inserted).descriptionDeleteButton();
          $(".custom-textile-container").descriptionTextareaField();
          $(".custom-editable-container").exhibitTextField();
          $inserted.insertTextareaValue();
          //$.fn.hydraExhibit.resetSetting();
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
          placeholder : "click to edit description",
          onblur    : "ignore",
          name      : "asset["+new_value_index+"]["+datastreamName+"]",
          id        : "field_id",
          height    : "100",          
          ckeditor  : { toolbar:
                        [   ['linkItem'],
                            ['Bold', 'Italic', '-', 'NumberedList', 'BulletedList', '-', 'Link', 'Unlink', '-', 'linkItem'],
                            ['Cut','Copy','Paste','PasteText','PasteFromWord','-','Print', 'SpellChecker', 'Scayt'],
                            ['UIColor', 'PageBreak'], ['Source'], ['Maximize', 'ShowBlocks','-','About']
                        ]
                      }
       });
     },

     deleteDescription: function(element){
       //$element = $(element)
       var $essayNode = $(element).closest(".remove-description-div")
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
   			$essayNode.animate({'backgroundColor':'#fb6c6c'},300);
         },
         success: function() {
           $essayNode.slideUp(300,function() {
             $essayNode.remove();
             //$.fn.hydraExhibit.resetSetting();
           });
         }
       });
     }
    };

 })(jQuery)

