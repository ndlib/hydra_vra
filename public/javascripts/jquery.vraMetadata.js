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
         alert("Need add new agent tag");
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
         alert("Need add new image tag");
         $.fn.vraMetadata.addImageTag("image_tag");
       });
     });
     return this;
   };

   $.fn.vraMetadata = {
     addAgent: function(type) {
       var content_type = $("form#new_agent > input#content_type").first().attr("value");
       var agent_selector = ".person";
       //alert("contributors_group_selector->"+agent_selector);
       var url = $("form#new_agent").attr("action");
       //alert("What is select" + $(agent_selector).last());

       $.post(url, {tag_type:type, content_type:content_type},function(data) {
         $(agent_selector).last().after(data);
         $inserted = $(agent_selector).last();
         $(".editable-container", $inserted).hydraTextField();
         //$("a.destructive", $inserted).hydraAgentDeleteButton();
       });
     },

     addImageTag: function(type) {
       var content_type = $("form#new_agent > input#content_type").first().attr("value");
       var image_selector = ".image_tag";
       //alert("contributors_group_selector->"+agent_selector);
       var url = $("form#new_image_tag").attr("action");
       alert("What is select" + $(image_selector).last());

       $.post(url, {tag_type:type, content_type: content_type},function(data) {
         $(image_selector).last().after(data);
         $inserted = $(image_selector).last();
         $(".editable-container", $inserted).hydraTextField();
         //$("a.destructive", $inserted).hydraAgentDeleteButton();
       });
     }

     /*TODO deleteContributor: function(element) {
       var content_type = $("form#new_contributor > input#content_type").first().attr("value");
       var url = $(element).attr("href");
       var $contributorNode = $(element).closest(".contributor")

       $.ajax({
         type: "DELETE",
         url: url,
         dataType: "html",
         beforeSend: function() {
   				$contributorNode.animate({'backgroundColor':'#fb6c6c'},300);
         },
   			 success: function() {
           $contributorNode.slideUp(300,function() {
             $contributorNode.remove();
   				});
         }
       });
     }*/

   };

   $.fn.hydraAgentDeleteButton = function(settings) {
     var config = {};

     if (settings) $.extend(config, settings);

     this.each(function() {
       $(this).unbind('click.hydra').bind('click.hydra', function(e) {
          $.fn.hydraMetadata.deleteContributor(this, e);
          e.preventDefault();
        })
     });

     return this;

   };

 })(jQuery);