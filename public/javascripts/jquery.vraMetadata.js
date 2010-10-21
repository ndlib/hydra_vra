  (function($) {
   /*  Initialize the form for inserting new Person (individual) permissions
   *  ex. $("#add-contributor-box").hydraNewContributorForm
   */
   $.fn.hydraNewAgentForm = function(settings) {
     var config = {};

     if (settings) $.extend(config, settings);

     this.each(function() {
       $("#re-run-add-agent-action", this).click(function() {
         addAgent("agent");
       });
     });

     return this;

   };

     addAgent: function(type) {
       var content_type = $("form#new_agent > input#content_type").first().attr("value");
       var contributors_group_selector = "."+type+".contributor";

       var url = $("form#new_agent").attr("action");

       $.post(url, {contributor_type: type, content_type: content_type},function(data) {
         $(contributors_group_selector).last().after(data);
         $inserted = $(contributors_group_selector).last()
         $(".editable-container", $inserted).hydraTextField();
         $("a.destructive", $inserted).hydraContributorDeleteButton();
       });
     }

 })(jQuery);