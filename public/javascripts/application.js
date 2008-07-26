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
    var elements = [$('piece_settings_voices_tab_link'), $('piece_settings_sections_tab_link')];
    if ($('advanced_options_toggle').getValue() == null) {      
      if (!$('piece_settings').visible()) {
        switchid('piece_settings');        
      }
      
      elements.invoke('hide');      
    } else {
      elements.invoke('show');      
    }       
}

function check_field_validity(select_function) {
    fields = live_validation_fields.select(select_function);
    var invalid_fields = fields.reject(function(field) {
      return field.get('validate')();
    });           
    
    if (invalid_fields.length == 0) return true;
    invalid_fields = invalid_fields.invoke('get', 'description');               
           
    alert('Please fix the following fields before continuing: \n\n' + invalid_fields.join('\n'));
    return false;
}

function remove_live_validation_fields(select_function) {
    live_validation_fields = live_validation_fields.reject(select_function);    
}

function remove_live_validation_fields_for_checkbox(checkbox_id) {
    remove_live_validation_fields(function(field) {
        return field.get('override_checkbox_id') == checkbox_id;
    });
}

function remove_live_validation_fields_for_panel(panel_div_id) {
    remove_live_validation_fields(function(field) {
        return field.get('owning_panel_id') == panel_div_id && field.get('remove_on_panel_change');
    });
}
