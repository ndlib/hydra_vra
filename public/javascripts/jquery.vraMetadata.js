(function($) {
   /* Initialize the form for inserting new Person (individual) permissions
* ex. $("#add-contributor-box").hydraNewContributorForm
*/
  $.fn.hydraNewAgentForm = function(settings) {
     var config = {};
      //alert("Init HydraNewAgent");
     if (settings) $.extend(config, settings);
     this.each(function() {
         //alert("Need add new agent tag");
       $("#re-run-add-agent-action", this).click(function() {
         $.fn.vraMetadata.addAgent("agent");
       });
     });
     return this;
  };

   $.fn.hydraNewImageForm = function(settings) {
     var config = {};
     if (settings) $.extend(config, settings);

     this.each(function() {
       //alert("Add image this function");
       $("#re-run-add-image-action", this).click(function() {
         //alert("Need add new image tag");
         $.fn.vraMetadata.addImageTag("image_tag");
       });
     });
     return this;
   };

   $.fn.lotCreateButton = function(settings) {
     var config = {};
     //alert("lotCreateButtton")
     if (settings) $.extend(config, settings);
        $("#add_lot", this).live("click", function(){
         alert("lotCreateButtton live")
         var lot_key = $("input#lot_key").first().attr("value");
         //alert("Lot key enter: "+ lot_key)
         if (lot_key == "" || lot_key.length ==0) {
            alert("Please enter lot id before adding new lot")
            return false;
         }
         //alert("Calling create lot on click")
         $.fn.vraMetadata.createLot(this);
       });
   /*this.each(function() {
$("#add_lot", this).click(function(e) {
var lot_key = $("input#lot_key").first().attr("value");
//alert("Lot key enter: "+ lot_key)
if (lot_key == "" || lot_key.length ==0) {
alert("Please enter lot id before adding new lot")
return false;
}
//alert("Calling create lot on click")
$.fn.vraMetadata.createLot(this);
e.preventDefault();
});
});*/
     return this;
   };

   $.fn.agentDeleteButton = function(settings) {
     var config = {};
     if (settings) $.extend(config, settings);
     this.each(function() {
       //alert("Agent this function");
       $(this).unbind('click.hydra').bind('click.hydra', function(e) {
          $.fn.vraMetadata.deleteAgent(this, e);
          e.preventDefault();
        })
     });
     return this;
   };

   $.fn.imageDeleteButton = function(settings) {
     var config = {};
     if (settings) $.extend(config, settings);
     this.each(function() {
       //alert("Image this function");
       $(this).unbind('click.hydra').bind('click.hydra', function(e) {
          $.fn.vraMetadata.deleteImage(this, e);
          e.preventDefault();
        })
     });
     return this;
   };

   $.fn.lotDeleteButton = function(settings) {
     alert("lotDeleteButtton")
     var config = {};
     if (settings) $.extend(config, settings);
     //alert("before this function");
     /*this.each(function() {
//alert("this function");
$(this).unbind('click.hydra').bind('click.hydra', function(e) {
$.fn.vraMetadata.deleteLot(this, e);
e.preventDefault();
})
});*/
      $("a.destroy_lot", this).live("click", function(){
         alert("lotDeleteButtton live")
         $.fn.vraMetadata.deleteLot(this);
         //e.preventDefault();
      });
     return this;
   };

   $.fn.vraMetadata = {
     addAgent: function(type) {
       var content_type = $("form#new_agent > input#content_type").first().attr("value");
       var agent_selector = ".agent_set";
       //alert("contributors_group_selector->"+agent_selector);
       var url = $("form#new_agent").attr("action");
       //alert("What is select" + $(agent_selector).last());

       $.post(url, {tag_type:type, content_type:content_type},function(data) {
         $(agent_selector).last().after(data);
         $inserted = $(agent_selector).last();
         $(".editable-container", $inserted).hydraTextField();
         $("a.destructive", $inserted).agentDeleteButton();
       });
     },

     addImageTag: function(type) {
       var content_type = $("form#new_image_tag > input#content_type").first().attr("value");
       var image_selector = ".image_tag";
       var url = $("form#new_image_tag").attr("action");

       $.post(url, {tag_type:type, content_type: content_type},function(data) {
         $(image_selector).last().after(data);
         $inserted = $(image_selector).last();
         $(".editable-container", $inserted).hydraTextField();
         $("a.destructive", $inserted).imageDeleteButton();
       });
     },

     deleteAgent: function(element) {
       var content_type = $("form#new_agent > input#content_type").first().attr("value");
       var url = $(element).attr("href");
       var $agentNode = $(element).closest(".agent_set")
       //alert("Content type"+content_type);
       url=url+"&content_type="+content_type
       $.ajax({
         type: "DELETE",
         url: url,
         dataType: "html",
         beforeSend: function() {
            //alert("change color")
    $agentNode.animate({'backgroundColor':'#fb6c6c'},300);
         },
         success: function() {
           //alert("trying to hide")
           $agentNode.slideUp(300,function() {
             $agentNode.remove();
           });
         }
       });
     },

     deleteImage: function(element) {
       var content_type = $("form#new_image_tag > input#content_type").first().attr("value");
       var url = $(element).attr("href");
       var $imageNode = $(element).closest(".image_tag")
       //alert("Content type"+content_type);
       url=url+"&content_type="+content_type
       $.ajax({
         type: "DELETE",
         url: url,
         dataType: "html",
         beforeSend: function() {
            //alert("change color")
    $imageNode.animate({'backgroundColor':'#fb6c6c'},300);
         },
         success: function() {
           //alert("trying to hide")
           $imageNode.slideUp(300,function() {
             $imageNode.remove();
           });
         }
       });
     },

     createLot: function(el) {
       var lot_id = $("input#lot_key").first().attr("value");
       //alert("Lot id: "+lot_id)
       var url = $("input#create_lot_url").first().attr("value");//$(el).attr("action");
       var pid = $("div#lot").attr("data-pid");
       var params = "&building_pid="+pid+"&key="+lot_id;
       url=url+params;
       var lot_selector = ".lot_remove_test";
       var $lotNode = $(el).closest(".lot_remove_test");
       //alert("create Lot url"+url);
       $.post(url, function(data){
         $(lot_selector).last().after(data);
         $inserted = $(lot_selector).last();
         $(".editable-container", $inserted).hydraTextField();
         $("a.destructive", $inserted).lotDeleteButton();
         $lotNode.remove();
       });
     },

     deleteLot: function(element) {
       alert("Into Delete Lot"+$(element))
       var $lotNode = $(element).closest(".lot_tag")
       var url = $(element).attr("action");
       var building_pid = $("div#lot").attr("data-pid");
       var building_content_type = $("div#lot").attr("data-content-type");
       var content_model="Lot"
       var params = "?content_model="+content_model+"&building_pid="+building_pid+"&building_content_type="+building_content_type;
       url=url+params;
       //alert("URL: "+url);
       $.ajax({
         type: "DELETE",
         url: url,
         dataType: "html",
         beforeSend: function() {
            //alert("change color")
    $lotNode.animate({'backgroundColor':'#fb6c6c'},300);
         },
         success: function() {
           //alert("trying to hide")
           $lotNode.slideUp(300,function() {
             $lotNode.remove();
           });
         }
       });
     }


   };

 })(jQuery);