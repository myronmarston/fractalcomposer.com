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
