  (function($) {
   /*  Initialize the form for inserting new Person (individual) permissions
   *  ex. $("#add-contributor-box").hydraNewContributorForm
   */
  $.fn.hydraNewAgentForm = function(settings) {
     var config = {};
      //alert("Init HydraNewAgent");
     if (settings) $.extend(config, settings);

     this.each(function() {
       $("#re-run-add-agent-action", this).click(function() {
         //alert("Need add new agent tag");
         $.fn.vraMetadata.addAgent("agent");
       });
     });
     return this;
  };

   $.fn.hydraNewImageForm = function(settings) {
     var config = {};
     if (settings) $.extend(config, settings);

     this.each(function() {
       $("#re-run-add-image-action", this).click(function() {
         //alert("Need add new image tag");
         $.fn.vraMetadata.addImageTag("image_tag");
       });
     });
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

   $.fn.lotCreateButton = function(settings) {
     var config = {};
     //alert("lotCreateButtton")
     if (settings) $.extend(config, settings);
     this.each(function() {
       $("#add_lot", this).click(function() {
         var lot_key = $("input#lot_key").first().attr("value");
         //alert("Lot key enter: "+ lot_key)
         if (lot_key == "" || lot_key.length ==0) {
            alert("Please enter lot id before adding new lot")
            return false;
         }
         //alert("Calling create lot on click")
         $.fn.vraMetadata.createLot(this);
       });
     });
     return this;
   };

    $.fn.lotDeleteButton = function(settings) {
     //alert("lotDeleteButtton"+ this)
     var config = {};
     if (settings) $.extend(config, settings);
     //alert("before this function");
     this.each(function() {
       //alert("this function");
       //$("#destroy_lot", this).click(function() {
       $(this).unbind('click.hydra').bind('click.hydra', function(e) {
         alert("calling deleteLot");
         $.fn.vraMetadata.deleteLot(this, e);
         e.preventDefault();
       })
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
         $("a.destructive", $inserted).agentDeleteButton();
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
       var url = $(el).attr("action");
       var pid = $("div#lot").attr("data-pid");
       var params =  "&building_pid="+pid+"&key="+lot_id;
        url=url+params;
        //alert("URL is "+url);
       var lot_selector = ".lot_tag";
       $.post(url, function(data){
         //alert("created lot successfully");
         $(lot_selector).last().after(data);
         $inserted = $(lot_selector).last();
         $(".editable-container", $inserted).hydraTextField();
         $("a.destructive", $inserted).lotDeleteButton();
       });
     },

     deleteLot: function(element) {
       alert("Into Delete Lot"+$(element).html)
       var $lotNode = $(element).closest(".lot_tag")
       var url = $(element).attr("href");
       var building_pid = $("div#lot").attr("data-pid");
       var building_content_type = $("div#lot").attr("data-content-type");
       var content_model="Lot"
       var params =  "?content_model="+content_model+"&building_pid="+building_pid+"&building_content_type="+building_content_type;
       url=url+params;
       alert("URL: "+url);
       $.ajax({
         type: "DELETE",
         url: url,
         dataType: "html",
         beforeSend: function() {
            alert("change color")
   			$lotNode.animate({'backgroundColor':'#fb6c6c'},300);
         },
         success: function() {
           alert("trying to hide")
           $lotNode.slideUp(300,function() {
             $lotNode.remove();
           });
         }
       });
     }


   };

 })(jQuery);