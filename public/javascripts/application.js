// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function fireEvent(element,event){
  if (document.createEventObject){
    // dispatch for IE
    var evt = document.createEventObject();
    return element.fireEvent('on'+event,evt)
  } else{
    // dispatch for firefox + others
    var evt = document.createEvent("HTMLEvents");
    evt.initEvent(event, true, true ); // event type,bubbling,cancelable
    return !element.dispatchEvent(evt);
  }
}

function disableButton(element_id) {
    var element = $(element_id);
    element.disable();
    if (!element.hasClassName('disabled_button')) {
        element.addClassName('disabled_button');    
    }    
}

function enableButton(element_id) {
    var element = $(element_id);
    element.enable();
    if (element.hasClassName('disabled_button')) {
        element.removeClassName('disabled_button');    
    }    
}

function performAdvancedOptionsToggle() {    
    if ($('advanced_options_toggle').getValue() == null) {      
      if (!$('piece_settings').visible()) {
        switchid('piece_settings');        
      }
      
      $('piece_settings_voices_tab_link').hide();
      $('piece_settings_sections_tab_link').hide();
    } else {
      $('piece_settings_voices_tab_link').show();
      $('piece_settings_sections_tab_link').show();
    }       
}

var ComposeFieldMonitor = Class.create({
  initialize: function() {
    composeForm = $('compose_form')
    descdendant_elements = composeForm.descendants();
    
    this.descdendant_elements.each(function(field) {
      if (!field.hasClassName('submit_to_library_field')) {
        // we only want to monitor the fields used to generate the piece        
      }
    });
    
    this.element = $(element);
    this.fields = this.element.getElements();
    this.initFieldChecker();
  } // initialize
});

var FieldMonitor = Class.create({
  initialize: function(element) {
    this.element = $(element);
    this.fields = this.element.getElements();
    this.initFieldChecker();
  }, // initialize
  initFieldChecker: function() {
    // get the original values and populate the hash
    originalValues = new Hash();
    this.fields.each(function(field) {
      originalValues.set(field.id, $F(field));
    });
    // set up the observers on each field of the form
    this.fields.each( function(field) {
      new Form.Element.EventObserver(field, function(f, value) {
        var originalValue = originalValues.get(f.id);
        // if the value is the same as original, remove the class tag
        if ( originalValue === value) {
          f.removeClassName('changed_field')
        } else {
          // else the value is different from the original, add the class tag
          f.addClassName('changed_field')
        };
      })
    })
  } // initFieldChecker
});
