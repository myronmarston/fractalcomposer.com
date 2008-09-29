// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function LW$(id) {
  var lw_element = $('lightwindow_contents');
  if (lw_element == null) return $(id);
  
  var elements = lw_element.getElementsBySelector('#' + id);
  if (elements.size() == 0) return $(id);
  return elements[0];
}

function create_live_validation_field_basic(id, delay, validations) {    
  var insert_after_element = LW$(id + '-label');
  if (insert_after_element == null) insert_after_element = LW$(id);
  
  var options = {validMessage: '', wait: delay, insertAfterWhatNode: insert_after_element};
  if (id.match(/germ/)) {      
      options['onlyOnBlur'] = true;
  }
  
  var validator = new LiveValidation(LW$(id), options);
  
  validations.each (function(validation) {
    validator.add(validation.type, validation.args);    
  });  
       
  return validator;
}

function create_rounded_corners(id) {
  // the border is set for when javascript is disabled, but we want to disable
  // it and replace it with the rico rounded corner with border.
  $(id).setStyle({border: 'none'});
  Rico.Corner.round($(id), {bgColor: '#ffffff', border: '#9cc8f4;'});
}