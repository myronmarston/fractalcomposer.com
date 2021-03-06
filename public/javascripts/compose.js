/*
 * Contains javascript functions used by the compose page.
 */
 var live_validation_fields = new Array();
 
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

function validateVolumeAdjustmentFraction(valueToValidate, args) {    
    var failureMsg = 'Must be an integer or fraction between -1 and 1.';
    var match = args.pattern.exec(valueToValidate);
    if (null == match) {
        Validate.fail(failureMsg);
    } else {
        var numerator = Number(match[1]);
        var denominator = Number(match[2]); 
        var floatVal = (isNaN(denominator) ? numerator : numerator / denominator);
        if (floatVal <= -1 || floatVal > 1) {
            Validate.fail(failureMsg);
        }
    }
    return true;
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
                                      
function create_live_validation_field(id, delay, panel_div_id, voice_or_section_id, description, override_checkbox_id, validations) {    
  var validator = create_live_validation_field_basic(id, delay, validations);
       
  var field_hash = $H({ 
      id : id,      
      validate : function() {return validator.validate();}, 
      description : description,
      override_checkbox_id : override_checkbox_id,
      owning_panel_id : panel_div_id,
      owning_voice_or_section_id : voice_or_section_id,
      validate_on_generate_piece : !panel_div_id.empty(),
      validate_on_submit : panel_div_id.empty(),
      remove_on_panel_change : !override_checkbox_id.empty()
  });
                        
  live_validation_fields.push(field_hash);
  return validator;
}

function check_field_validity(select_function) {
    fields = live_validation_fields.select(select_function);
    var invalid_fields = fields.reject(function(field) {
      return field.get('validate')();
    });           
    
    if (invalid_fields.length == 0) return true;
    invalid_fields = invalid_fields.invoke('get', 'description');               
           
    alert('There are some fields with invalid values.  Please fix the following fields before continuing: \n\n' + invalid_fields.join('\n'));
    return false;
}

function update_submit_form_result(new_content) {
    LW$('submit_to_library_result_wrap').update(new_content);
}

function check_field_validity_for_voice_or_section(voice_or_section_id) {
  return check_field_validity(function(f) {
    return f.get('owning_voice_or_section_id') === voice_or_section_id;          
  });  
}

function check_field_validity_for_voice_section() {
  // TODO: there should be a lot more fields we can eliminate,
  //       but we need to find the way to get the 'owning' voice or section
  return check_field_validity(function(f) {
    return f.get('owning_panel_id') !== 'piece_settings' && f.get('validate_on_generate_piece');          
  });  
}

function check_field_validity_for_germ() {
  return check_field_validity(function(f) {
    return f.get('owning_panel_id') === 'piece_settings';          
  });
}

function check_field_validity_for_generate_piece() {
  return check_field_validity(function(f) {
    return f.get('validate_on_generate_piece');          
  });
}

function check_field_validity_for_submit_to_library() {  
  return check_field_validity(function(f) {
    return f.get('validate_on_submit');          
  });
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

function remove_live_validation_fields_for_voice_or_section(voice_or_section_id) {
    remove_live_validation_fields(function(field) {
        return field.get('owning_voice_or_section_id') == voice_or_section_id;
    });
}

function remove_live_validation_fields_for_submit_form() {
    remove_live_validation_fields(function(field) {
        return field.get('validate_on_submit');
    });    
}

function delete_voice_or_section(plural_voices_or_sections_label, singular_voices_or_sections_label, div_id, voice_or_section_index, server_notification_url) {                     
    if ($(plural_voices_or_sections_label).getElementsBySelector('div.one_voice_or_section').length == 1) {
        alert('You cannot delete the last ' + singular_voices_or_sections_label + '.  There must always be at least one.');
    } else {
        Effect.DropOut(div_id);
        new Ajax.Request(server_notification_url, 
          {asynchronous:true, 
           evalScripts:true, 
           parameters:'voice_or_section=' + singular_voices_or_sections_label + '&unique_index=' + voice_or_section_index});
        remove_live_validation_fields_for_voice_or_section(div_id);
        setTimeout("$('" + div_id + "').remove()", 1000);
    }
    
    return false;
}

function resizeLightwindow() {
    myLightWindow.resizeTo.height = $('lightwindow_contents').scrollHeight+(myLightWindow.options.contentOffset.height);
    myLightWindow.resizeTo.width = $('lightwindow_contents').scrollWidth+(myLightWindow.options.contentOffset.width);       
    myLightWindow._processWindow();    
}

function launchLightwindow_autoSize(href, title) {      
    myLightWindow.activateWindow({
      href: href,
      title: title,
      type: 'inline'
    });            
}

function launchLightwindow_autoHeight(href, title, width) {      
    myLightWindow.activateWindow({
      href: href,
      title: title,
      type: 'inline',
      width: width
    });            
}

function launchLightwindow(href, title, height, width) {   
    myLightWindow.activateWindow({
      href: href,
      title: title,
      type: 'inline',
      height: height,
      width: width
    });            
}

function launchListeningPopupAjax(validation_function, ajax_url, spinner_id, title, serialize_id, other_params) {    
    if (validation_function()) {
      $(spinner_id).show();
      new Ajax.Request(ajax_url, 
        {asynchronous:true, 
         evalScripts:true, 
         onComplete:function(request){
             $(spinner_id).hide(); 
             launchLightwindow('#hidden_content_for_lightwindow', title, 500, 770);
         }, 
         parameters:Form.serialize($(serialize_id)) + other_params});         
    } 
}

function generatePiece(spinner_id, ajax_url) {
    launchListeningPopupAjax(check_field_validity_for_generate_piece, ajax_url, spinner_id, 'Your Fractal Piece', 'compose_form', '');
}