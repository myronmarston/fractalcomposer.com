require 'uuidtools.rb'

module ComposeHelper
  extend PathHelper
  
  LIVE_VALIDATION_DELAY = 600 unless defined? LIVE_VALIDATON_DELAY
  
  def field_wrap(field_id, label, after_input_content, *live_validation_args, &block)
    # technique taken from http://groups.google.com/group/rubyonrails-talk/browse_thread/thread/e911d16cdf90cace/422230f7d8674cc7?lnk=gst&q=helper+block#422230f7d8674cc7
    content = capture(&block)
    
    info_name = label.titleize.gsub(' ', '').underscore
        
    info_div = content_tag(:div, info(info_name, field_id), :class => 'field-info', :id => "#{field_id}-info")
    content_div = content_tag(:div, content, :class => 'field-input') 
    label_div = content_tag(:div, label, :class => 'field-label', :id => "#{field_id}-label") #+ '<div class="LV_validation_message LV_invalid">Must be an integer or fraction between -1 and 1.</div>'
    live_validation = live_validation_args.size > 0 ? get_live_validation_js(*live_validation_args) : ''
    wrap_div = content_tag(:div, info_div + content_div + after_input_content + label_div + live_validation, :class => 'field-wrap', :id => "#{field_id}-wrap")        
    
    concat wrap_div, block.binding
  end
  
  def get_additional_tab_javascript(tab_name)       
    # notify the controller that the user has finished editing this tab,
    # so that it can update the voice sections to keep everything in sync
    additional_js = "remove_live_validation_fields_for_panel('#{tab_name}'); "
    additional_js += remote_function(:url => {
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
  
  def get_add_voice_or_section_js(singular_voices_or_sections_label, spinner_id)
    add_voice_or_section_js = remote_function(        
        :url => {:action => 'add_voice_or_section_xhr'}, 
        :with => "'voice_or_section=#{singular_voices_or_sections_label}'") + 
        "; $('#{spinner_id}').show()" 
    
    # this javascript does the following:
    # - Gives the user an error message if they are trying to add a 17th voice
    # - Otherwise, call the remote function on the server, which will add the voice and update the page
    return add_voice_or_section_js unless singular_voices_or_sections_label == 'voice'
    
    <<-END_OF_STRING
        if (#{get_prototype_js_for_element_collection(singular_voices_or_sections_label.pluralize, 'div.one_voice_or_section')}.length == 16) {
            alert('You cannot add more than 16 voices.');
        } else {            
            #{add_voice_or_section_js};            
        }
    END_OF_STRING
  end    
  
 def get_scale_or_key_observe_field(id_of_field_to_observe, scale_id, key_id, scale_spinner_id, input_prefix, id_to_serialize)                
    if id_to_serialize
      with = "Form.serialize($('#{id_to_serialize}')) + "
    else
      with = "'scale=' + encodeURIComponent($('#{scale_id}').value) + " +
             "'&key=' + encodeURIComponent($('#{key_id}').value) + "    
    end
               
    with += "'&input_prefix=#{input_prefix}'"           
    before = "$('#{scale_spinner_id}').show();"
    complete = "$('#{scale_spinner_id}').hide();"
        
    observe_field id_of_field_to_observe, :url => { :action => :scale_selected_xhr }, :with  => with, :before  => before, :complete  => complete
  end    
    
  def get_override_checkbox_onclick_javascript(checkbox_id, loading_div_id, content_div_id, action, with)
                   
    remote_func_js = remote_function(
      :url => {:action => action},
      :with => with,
      :before    => "$('#{checkbox_id}').disable(); $('#{loading_div_id}').show();",
      :complete  => "$('#{checkbox_id}').enable();  $('#{loading_div_id}').hide();")
    
    <<-END_OF_STRING
      if ($('#{checkbox_id}').checked) {
        #{remote_func_js}        
      } else {
        remove_live_validation_fields_for_checkbox('#{checkbox_id}');
        Element.update('#{content_div_id}', '');
      }
    END_OF_STRING
    
  end
  
  def get_voice_section_override_checkbox_onclick_javascript(checkbox_id, loading_div_id, content_div_id, parent_voice_or_section_id, settings_type, main_unique_index, other_unique_index)
    js = get_override_checkbox_onclick_javascript(
      checkbox_id, loading_div_id, content_div_id,
      'get_voice_section_overriden_settings_xhr',
      "Form.serialize($('#{parent_voice_or_section_id}')) + " +
      "'&voices_or_sections=#{@voices_or_sections_label}" +
      "&settings_type=#{settings_type}" +
      "&main_unique_index=#{main_unique_index}" + 
      "&other_unique_index=#{other_unique_index}" + 
      "&override_checkbox_id=#{checkbox_id}" +
      "&settings_content_wrap_id=#{content_div_id}'"    
    )
    
    js_function = "function() {#{js};}"
    
    javascript_tag("Event.observe('#{checkbox_id}', 'click', #{js_function})")
  end
  
  def set_prefix_instance_variables
    # set prefix instance variables used by multiple partials
    if @voices_or_sections_label && @voice_or_section
      index = @voice_or_section.getUniqueIndex
      @voice_or_section_id = get_one_voice_or_section_id
      @voice_or_section_input_name_prefix = "#{@voices_or_sections_label}[#{index}]"
      @voice_or_section_input_id_prefix = sanatize_input_id(@voice_or_section_input_name_prefix)             
      
      @current_item_description = "#{@voices_or_sections_label.singularize.titleize} #{index}"
      if @voice_section
        @this_type_unique_index = index
        @other_type_unique_index = @voice_section.getOtherVoiceOrSection(@voice_or_section).getUniqueIndex    
        @other_type_label = @voice_section.getOtherVoiceOrSection(@voice_or_section).getClassName
        @voice_section_input_name_prefix = "#{@voices_or_sections_label}[#{@this_type_unique_index}][voice_sections][#{@other_type_unique_index}]"
        @voice_section_input_id_prefix = sanatize_input_id(@voice_section_input_name_prefix)  
        
        @current_item_description = "Voice Section for #{@current_item_description}, #{@other_type_label.singularize.titleize} #{@other_type_unique_index}"
      end    
    end            
  end
  
  def set_scale_key_prefix_instance_variables(input_prefix)    
    @scale_name = (input_prefix == '' ? 'scale' : "#{input_prefix}[scale]")
    @scale_id = sanatize_input_id(@scale_name)
    @scale_spinner_id = (input_prefix == '' ? 'scale_spinner' : sanatize_input_id("#{input_prefix}_scale_spinner"))
    @key_name = (input_prefix == '' ? 'key' : "#{input_prefix}[key]")
    @key_id = sanatize_input_id(@key_name)
    @key_name_selection_span = (input_prefix == '' ? 'key_name_selection' : sanatize_input_id("#{input_prefix}_key_name_selection"))
  end
  
  def get_one_voice_or_section_id
    "#{@voices_or_sections_label.singularize}_#{@voice_or_section.getUniqueIndex}"      
  end
    
  def get_live_validation_js(id, validate_now, panel_div_id, voice_or_section_id, description, override_checkbox_id, validations)                  
    js = <<-EOS
      var #{get_live_validation_var_name(id)} = create_live_validation_field('#{id}', #{LIVE_VALIDATION_DELAY}, '#{panel_div_id}', '#{voice_or_section_id}', '#{description}', '#{override_checkbox_id}', [#{validations}]);
    EOS
    javascript_tag(js)  
  end    
  
  def get_live_validation_var_name(id)
    "#{id}_validator"
  end
  
  def info(name, id = nil, content_after_info_icon = nil, icon_style = nil, info_wrap_div_class = nil)    
    render :partial => 'field_info', 
           :locals => {:name => name, 
                       :id => id, 
                       :content_after_info_icon => content_after_info_icon, 
                       :icon_style => icon_style, 
                       :info_wrap_div_class => info_wrap_div_class}
  end
  
  def get_guido_image_url(guido_filename)
    orig_px_per_cm = 48.0
    zoom = 0.81 # values less than 0.81 sometimes lead to no ledger lines
    px_per_cm = orig_px_per_cm * zoom
    width = 700
    
    image_url =  'http://clef.cs.ubc.ca/scripts/salieri/gifserv.pl?'
    image_url << "defpw=#{((width / px_per_cm) * 10).to_i / 10.0}cm;"
    image_url << 'defph=100.0cm;'            
    image_url << "zoom=#{zoom};"    
    image_url << 'crop=yes;'
    image_url << 'mode=gif;'
    
    # unused parameters:
    #image_url << 'markvoice=;'
    #image_url << 'rtp=;'
    #http://clef.cs.ubc.ca/scripts/salieri/gifserv.pl?defpw=10.0cm;defph=24.0cm;zoom=1.0;markvoice=;rtp=;crop=yes;mode=gif;gmndata=%5B%5Cmeter%3C%224%2F4%22%3E%20c%20d%20e%20f%20g%20a%20h%20c%20d%20e%20%20%5D;gmnurl=;midiurl=;mdurl=;submit=%20%20%20Send%20%20        
    
    if (request.host =~ /localhost/)
      # We're running on my development machine and the Guido note server can't
      # access a gmn file here, so put the whole guido string in the image URL.
      # Sometimes the URL will be too long and we'll get an empty image, but since this
      # is just running locally, it's ok.
      
      guido_string = ''
      File.open(ComposeHelper.get_local_filename(guido_filename), 'r') { |f| guido_string = f.read }      
      image_url << 'gmndata=' + CGI::escape(guido_string) + ';'      
    else
      # We're live on the internet, so the Guido note server can access our 
      # gmn file.  This is the preferred way since the URL won't be too long.
      
      image_url << 'gmnurl=' + CGI::escape(ComposeHelper.get_full_url_filename(guido_filename, request) + '?' + Time.now.to_i.to_s) + ';'
    end
       
    return image_url    
  end
  
  def get_generate_piece_button_js(piece_spinner_id)
    js = <<-EOS
      function() {
        generatePiece('#{piece_spinner_id}', '#{url_for(:action => 'generate_piece_xhr')}')
      }
    EOS
    
    javascript_tag("Event.observe('generate_piece_button', 'click', #{js})")
  end
  
  def get_open_submit_to_library_form_button_js(spinner_id)    
    remote_js = remote_function(
      :url => {:action => 'open_submit_to_library_form_xhr'},
      :with => "$('compose_form').serialize()",
      :before => "$('#{spinner_id}').show()",
      :complete => "$('#{spinner_id}').hide()")
    
    js = <<-EOS
      function() {
        if (check_field_validity_for_generate_piece()) {
          #{remote_js}
        }
      }
    EOS
    
    javascript_tag("Event.observe('open_submit_to_library_form_button', 'click', #{js})")
  end
    
  def listen_to_part_link(part_description, serialize_id, id_prefix, part_type, other_params)                
    validation_function = case part_type
      when 'germ' then 'check_field_validity_for_germ'
      when 'voice_section' then 'check_field_validity_for_voice_section'
      when /^(voice|section)$/ then "function() {return check_field_validity_for_voice_or_section('#{serialize_id}')}"
      else raise "Unexpected type: #{part_type}"
    end   
    
    spinner_id = "#{id_prefix}_listen_spinner"
    html = render(:partial => 'spinner', :locals => {:display => 'none', :div_id => spinner_id, :bottom_px => 1}) 
    id = "#{id_prefix}_listen_link"
    
    html << link_to(
        image_tag('music_blue.png', 
          :class => 'icon', 
          :alt => "Listen to #{part_description}",
          :title => "Listen to #{part_description}"), 
        '#',
        :onclick => 'return false',
        :id => id)
   
    js_function = <<-EOS
      function() {
        launchListeningPopupAjax(
          #{validation_function},
          '#{url_for(:action => 'listen_to_part_xhr')}', 
          '#{spinner_id}', 
          '#{part_description}', 
          '#{serialize_id}', 
          '&part_type=#{part_type}#{other_params}'
        );         
      }
    EOS
                  
    html << javascript_tag("Event.observe('#{id}', 'click', #{js_function})")
    
    return html
  end
  
  def get_doc_load_js     
    js = <<-EOS
      document.observe('dom:loaded', function() {
        performAdvancedOptionsToggle();
      });
    EOS
    javascript_tag(js)
  end
  
  def get_tab_click_handler(from_panel_div_id, to_panel_div_id, tab_link_id)     
    # yes, this is a hack...
    js = if (params[:action] == 'examples')
      <<-EOS          
      function() {
        switch_tab('#{to_panel_div_id}', ['example_1', 'example_2']);    
        return false;    
      }
      EOS
    else   
      <<-EOS    
      function() {
        if (check_field_validity(function(f) { 
              return f.get('owning_panel_id') == '#{from_panel_div_id}'; 
        })) {
            switch_tab('#{to_panel_div_id}', ['piece_settings', 'voices', 'sections']);
            #{get_additional_tab_javascript(from_panel_div_id)}
        } 

        return false;    
      }
      EOS
    end
    
    javascript_tag("Event.observe('#{tab_link_id}', 'click', #{js})")
  end    
 
end
