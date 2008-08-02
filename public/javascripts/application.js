// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function create_live_validation_field_basic(id_or_element, delay, validations) {    
  var validator = new LiveValidation(id_or_element, {validMessage: null, wait: delay});
  
  validations.each (function(validation) {
    validator.add(validation.type, validation.args);    
  });  
       
  return validator;
}