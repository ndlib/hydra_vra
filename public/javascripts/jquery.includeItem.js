$(function() {
  $("div.document div.documentHeader div h2.index_title a").bind("click", function(){
    var href = $(this).attr('href');

    var dialog = window.opener.CKEDITOR.dialog.getCurrent();
    var parent = window.opener.document;
    var url=decodeURI(window.opener.document.URL)
    var old_params=url.split('?')
    var params=""
    if(old_params[old_params.length-1].indexOf("exhibit_id")>0)
    {
      params=old_params[old_params.length-1]+"&viewing_context=browse"
    }
    else
    {
      //console.log($('form#document_metadata', window.opener.document).attr('data-pid'));
      var exhibit_id=$('form#document_metadata', window.opener.document).attr('data-pid')
      params="exhibit_id="+exhibit_id+"&render_search=false&viewing_context=browse"
    }
    if(href.indexOf("?")>0)
      {var new_url=href+"&"+params}
    else
      {var new_url=href+"?"+params}
    //console.log("url-> "+new_url)
    dialog.setValueOf('info','url',new_url);  // Populates the URL field in the Links dialogue.
    dialog.setValueOf('info','protocol','');  // This sets the Link's Protocol to Other which loads the file from the same folder the link is on
    dialog.setValueOf('info','displayField',$(this).html());  // Populates the display field in the Links dialogue
    window.close(); // closes the popup window
    return false;
  });
});