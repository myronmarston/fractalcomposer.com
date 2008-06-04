module ComposeHelper
  
  def get_additional_tab_javascript(tab_name)       
    # notify the controller that the user has finished editing this tab,
    # so that it can update the voice sections to keep everything in sync
    additional_js = remote_function(:url => {
        :action => 'finished_editing_tab_xhr'}, 
        :with => "Form.serialize($('#{tab_name}'))") + "; "
      
    # we only want this javascript to be for voices and sections....
    return additional_js unless tab_name == 'voices' || tab_name == 'sections'
    
    # show the "Loading..." div for the voice sections
    additional_js += get_prototype_js_do_method_on_element_collection(tab_name, 'div.voice_sections_loading_wrap', 'show')
    
    # remove the voice sections fieldsets, as they will get out of date if they are edited on the other tab
    additional_js += get_prototype_js_do_method_on_element_collection(tab_name, 'div.voice_sections_wrap', 'remove')
    
    # show the voice sections toggle link
    additional_js += get_prototype_js_do_method_on_element_collection(tab_name, 'a.voice_sections_toggle_link', 'show')
    
    # hide the voice sections fieldset
    additional_js += get_prototype_js_do_method_on_element_collection(tab_name, 'fieldset.voice_sections_fieldset', 'hide')        
  end
  
  def get_prototype_js_do_method_on_element_collection(parent_element_id, css_element_selector, prototype_method)
    "#{get_prototype_js_for_element_collection(parent_element_id, css_element_selector)}.each(function(e) {e.#{prototype_method}();}); "
  end
  
  def get_prototype_js_for_element_collection(parent_element_id, css_element_selector)
    "$('#{parent_element_id}').getElementsBySelector('#{css_element_selector}')"
  end
  
  def get_delete_voice_or_section_js(voices_or_sections_label, voice_or_section, div_id)
    singular_voices_or_sections_label = voices_or_sections_label.singularize
    plural_voices_or_sections_label = voices_or_sections_label.pluralize
    notify_server_js = remote_function(:url => {:action => :delete_voice_or_section_xhr}, :with => "'voice_or_section=#{singular_voices_or_sections_label}&amp;unique_index=#{voice_or_section.getUniqueIndex}'")
    # this javascript does the following:
    # 1. Gives the user an error message if they are trying to delete the last voice or section
    # 2. Visually show the user the delete
    # 3. Notify the server of the delete using AJAX so that it can modify the actual object
    # 4. After a delay, remove the html element.  The delay is necessary to allow the effect to complete.
    <<-END_OF_STRING
        if (#{get_prototype_js_for_element_collection(plural_voices_or_sections_label, 'div.one_voice_or_section')}.length == 1) {
            alert('You cannot delete the last #{singular_voices_or_sections_label}.  There must always be at least one.');
        } else {
            Effect.DropOut('#{div_id}');
            #{notify_server_js};
            setTimeout(\"$('#{div_id}').remove()\", 1000);
        }
    END_OF_STRING
  end
  
  def get_scale_or_key_observe_field(fieldname)
    observe_field fieldname, 
        :url => { :action => :scale_selected_xhr },                  
        :with  => "'scale=' + encodeURIComponent($('scale').value) + '&key=' + encodeURIComponent($('key').value)",
        :before  => "$('scale_spinner').show(); $('germ_spinner').show(); $('germ_midi_player_wrapper').hide()",
        :complete  => "$('scale_spinner').hide(); $('germ_spinner').hide(); $('germ_midi_player_wrapper').show()"        
  end    
  
  def get_override_checkbox_onclick_javascript(parent_voice_or_section_id, settings_type, checkbox_id, loading_div_id, content_div_id, main_unique_index, other_unique_index)
                   
    remote_func_js = remote_function(
      :url => {:action => 'get_voice_section_overriden_settings_xhr'},
      :with => "Form.serialize($('#{parent_voice_or_section_id}')) + " +
               "'&amp;voices_or_sections=#{@voices_or_sections_label}" +
               "&amp;settings_type=#{settings_type}" +
               "&amp;main_unique_index=#{main_unique_index}" + 
               "&amp;other_unique_index=#{other_unique_index}" + 
               "&amp;settings_content_wrap_id=#{content_div_id}'",
      :before    => "$('#{checkbox_id}').disable(); $('#{loading_div_id}').show();",
      :complete  => "$('#{checkbox_id}').enable();  $('#{loading_div_id}').hide();")
    
    <<-END_OF_STRING
      if ($('#{checkbox_id}').checked) {
        #{remote_func_js}        
      } else {
        Element.update('#{content_div_id}', '');
      }
    END_OF_STRING
    
  end
  
  def set_prefix_instance_variables
    # set prefix instance variables used by multiple partials
    if @voices_or_sections_label && @voice_or_section
      @voice_or_section_input_name_prefix = "#{@voices_or_sections_label}[#{@voice_or_section.getUniqueIndex}]"
      @voice_or_section_input_id_prefix = sanatize_input_id(@voice_or_section_input_name_prefix)             
    
      if @voice_section
        @this_type_unique_index = @voice_or_section.getUniqueIndex
        @other_type_unique_index = @voice_section.getOtherVoiceOrSection(@voice_or_section).getUniqueIndex    
        @other_type_label = @voice_section.getOtherVoiceOrSection(@voice_or_section).getClassName
        @voice_section_input_name_prefix = "#{@voices_or_sections_label}[#{@this_type_unique_index}][voice_sections][#{@other_type_unique_index}]"
        @voice_section_input_id_prefix = sanatize_input_id(@voice_section_input_name_prefix)  
      end    
    end    
  end
  
end
