/*
Copyright (c) 2003-2010, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config )
{
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
	// config.uiColor = '#AADC6E';

    config.extraPlugins = 'linkItem';
    config.removePlugins = 'scayt,menubutton,contextmenu';
};

    CKEDITOR.on( 'instanceReady', function( ev )
       {
          ev.editor.dataProcessor.writer.setRules( 'p',
             {
                indent : false,
                breakBeforeOpen : false,
                breakAfterOpen : false,
                breakBeforeClose : false,
                breakAfterClose : false
             });
       });

    CKEDITOR.on( 'dialogDefinition', function( ev )
    {
      // Take the dialog name and its definition from the event data.
      var dialogName = ev.data.name;
      var dialogDefinition = ev.data.definition;

      // Check if the definition is from the dialog we're
      // interested in (the 'linkItem' dialog).
      if ( dialogName == 'linkItem' )
      {
         // Remove the 'Target' and 'Advanced' tabs from the 'Link' dialog.
         dialogDefinition.removeContents( 'target' );
         dialogDefinition.removeContents( 'advanced' );

         // Get a reference to the 'Link Info' tab.
         var infoTab = dialogDefinition.getContents( 'info' );

         // Remove unnecessary widgets from the 'Link Info' tab.
         infoTab.remove( 'linkType');
         //infoTab.remove( 'protocol');
      }
    });
