// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function create_live_validation_field_basic(id_or_element, delay, validations) {    
  var validator = new LiveValidation(id_or_element, {validMessage: null, wait: delay});
  
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