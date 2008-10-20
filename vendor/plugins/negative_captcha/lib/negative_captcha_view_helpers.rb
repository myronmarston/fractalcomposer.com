module NegativeCaptchaViewHelpers
  def negative_captcha(captcha, id_suffix='')
    [
      hidden_field_tag('timestamp', captcha.timestamp.to_i, :id => "timestamp#{id_suffix}"), 
      hidden_field_tag('spinner', captcha.spinner, :id => "spinner#{id_suffix}"), 
    ].join
  end
  #TODO: autocomplete? autocomplete=off prevents browsers from filling in honey pots
  def negative_text_field_tag(negative_captcha, field, value, options={})
    id_suffix = options.delete(:id_suffix) || ''
    
    options[:id] = "#{negative_captcha.fields[field]}#{id_suffix}"
    nc_id = "#{field}#{id_suffix}"

    text_field_tag(negative_captcha.fields[field], value, options.merge(:tabindex => '1')) +
    content_tag('div', :style => 'position: absolute; left: -2000px;') {
      text_field_tag(field, '', :tabindex => '999', :id => nc_id)
    }
  end
  
  def negative_text_area_tag(negative_captcha, field, value, options={})
    id_suffix = options.delete(:id_suffix) || ''
    
    options[:id] = "#{negative_captcha.fields[field]}#{id_suffix}"
    nc_id = "#{field}#{id_suffix}"

    text_area_tag(negative_captcha.fields[field], value, options.merge(:tabindex => '1')) +
    content_tag('div', :style => 'position: absolute; left: -2000px;') {
      text_area_tag(field, '', :tabindex => '999', :rows => 2, :cols => 30, :id => nc_id)
    }
  end
  
  #TODO: Select, check_box, etc
end
