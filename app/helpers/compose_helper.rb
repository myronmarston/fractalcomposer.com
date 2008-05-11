module ComposeHelper
  
  def get_additional_tab_javascript(tab_name)
    # we only want this javascript to be for voices and sections....
    return '' unless tab_name == 'voices' || tab_name == 'sections'
    
    # notify the controller that the user has finished editing this tab,
    # so that it can update the voice sections to keep everything in sync
    additional_js = remote_function(:url => {
        :action => 'finished_editing_tab_xhr'}, 
        :with => "Form.serialize($('#{tab_name}'))") + "; "
      
    # show the "Loading..." div for the voice sections
    additional_js += get_prototype_js_for_element_collection(tab_name, 'div.voice_sections_loading_wrap', 'show')
    
    # remove the voice sections fieldsets, as they will get out of date if they are edited on the other tab
    additional_js += get_prototype_js_for_element_collection(tab_name, 'div.voice_sections_wrap', 'remove')
    
    # show the voice sections toggle link
    additional_js += get_prototype_js_for_element_collection(tab_name, 'a.voice_sections_toggle_link', 'show')
    
    # hide the voice sections fieldset
    additional_js += get_prototype_js_for_element_collection(tab_name, 'fieldset.voice_sections_fieldset', 'hide')        
  end
  
  def get_prototype_js_for_element_collection(parent_element_id, css_element_selector, prototype_method)
    "$('#{parent_element_id}').getElementsBySelector('#{css_element_selector}').each(function(e) {e.#{prototype_method}();}); "
  end
  
end
