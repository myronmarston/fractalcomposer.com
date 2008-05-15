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
  
end
