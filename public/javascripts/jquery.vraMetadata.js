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
       $(this).unbind('click.hydra').bind('click.hydra', function(e) {
          $.fn.vraMetadata.deleteAgent(this, e);
          e.preventDefault();
        })
     });
     return this;
   };

   $.fn.lotCreateButton = function(settings) {
     var config = {};
     alert("lotCreateButtton")
     if (settings) $.extend(config, settings);
     this.each(function() {
       $("#add_lot", this).click(function() {
         var lot_key = $("input#lot_key").first().attr("value");
         alert("Lot key enter: "+ lot_key)
         if (lot_key == "" || lot_key.length ==0) {
            alert("Please enter lot id before adding new lot")
            return false;
         }
         alert("Calling create lot on click")
         $.fn.vraMetadata.createLot(this);
       });
     });
     return this;
   };

    $.fn.lotDeleteButton = function(settings) {
     var config = {};
     if (settings) $.extend(config, settings);
     this.each(function() {
       $(this).unbind('click.hydra').bind('click.hydra', function(e) {
          $.fn.vraMetadata.deleteAgent(this, e);
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
       var content_type = $("form#new_agent > input#content_type").first().attr("value");
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
       var $agentNode = $(element).closest(".agent")
       alert("Content type"+content_type);
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

     createLot: function(el) {
       var lot_id = $("input#lot_key").first().attr("value");
       alert("Lot id: "+lot_id)
       var url = $(el).attr("action");
       var pid = $("div#lot").attr("data-pid");
       var params =  "&building_pid="+pid+"&key="+lot_id;
        url=url+params;
        alert("URL is "+url);
       var lot_selector = ".lot_tag";
       /*$.ajax({
         type: "post",
         url: url,
         beforeSend: function() {
                //alert("going to create lot ");
   				$fileAssetNode.animate({'backgroundColor':'#fb6c6c'},300);
   			},
            success: function() {
                alert("created lot successfully");
                $(lot_selector).last().after(data);
                $inserted = $(lot_selector).last();
                $(".editable-container", $inserted).hydraTextField();
                $("a.destructive", $inserted).lotDeleteButton();
            }
       });         */
       $.post(url, function(data){
         alert("created lot successfully");
         $(lot_selector).last().after(data);
         $inserted = $(lot_selector).last();
         $(".editable-container", $inserted).hydraTextField();
         $("a.destructive", $inserted).lotDeleteButton();
       });
     }

   };

 })(jQuery);