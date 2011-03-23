// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
  // make buttons jquery-ui elements
  $('button, input:submit, input.button').button()

	// for create asset button at the top
  $("#re-run-action").next().button( {
    text: false,
    icons: { primary: "ui-icon-triangle-1-s" }
  })
  .click(function() {
    $('#create-asset-menu').is(":hidden") ? 
      $('#create-asset-menu').show() : $('#create-asset-menu').hide();
    })
  .parent().buttonset();
	
	if ($('#content_type').val()) {
		the_selected_content_type = $('#content_type').val();
		the_selected_content_type_label = $('#create-asset-menu li[onclick*="' + the_selected_content_type + '"]').html();
//		$("#re-run-action").val(the_selected_content_type_label);
//		$('#re-run-action')[0].onclick = function(){ location.href='/assets/new?content_type=' + the_selected_content_type; };		
	}
	
	
  
  $('#create-asset-menu').mouseleave(function(){
    $('#create-asset-menu').hide();
  });

  // for add contributor (in edit article/dataset)
  $("#re-run-add-contributor-action").next().button( {
    text: false,
    icons: { primary: "ui-icon-triangle-1-s" }
  })
  .click(function() {
    $('#add-contributor-menu').is(":hidden") ? 
      $('#add-contributor-menu').show() : $('#add-contributor-menu').hide();
    })
  .parent().buttonset();
  
  $('#add-contributor-menu').mouseleave(function(){
    $('#add-contributor-menu').hide();
  });

  $("div.document div.documentHeader div h2.index_title a").bind("click", function(){
    var href = $(this).attr('href');
    //alert($(this).html())
    var dialog = window.opener.CKEDITOR.dialog.getCurrent();
    dialog.setValueOf('info','url',href);  // Populates the URL field in the Links dialogue.
    dialog.setValueOf('info','protocol','');  // This sets the Link's Protocol to Other which loads the file from the same folder the link is on
    dialog.setValueOf('info','displayField',$(this).html());  // Populates the display field in the Links dialogue
    window.close(); // closes the popup window
    return false;
  });

});

function createAssetNavigateTo(elem, link) {
  $('#re-run-action')
  .attr('value', $(elem).text())
  .click(function() {
    $('#create-asset-menu').hide();
    location.href = link;
  });

  location.href = link;
}
