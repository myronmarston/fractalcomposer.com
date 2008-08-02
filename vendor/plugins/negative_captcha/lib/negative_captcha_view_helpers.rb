module NegativeCaptchaViewHelpers
  def negative_captcha(captcha)
    [
      hidden_field_tag('timestamp', captcha.timestamp.to_i), 
      hidden_field_tag('spinner', captcha.spinner),
    ].join
  end
  #TODO: autocomplete?
  def negative_text_field_tag(negative_captcha, field, value, options={})
    text_field_tag(negative_captcha.fields[field], value, options.merge(:tabindex => '1', :id => "id_#{negative_captcha.fields[field]}")) +
    content_tag('div', :style => 'position: absolute; left: -2000px;') {
      text_field_tag(field, '', :tabindex => '999')
    }
  end
  
  def negative_text_area_tag(negative_captcha, field, value, options={})
    text_area_tag(negative_captcha.fields[field], value, options.merge(:tabindex => '1', :id => "id_#{negative_captcha.fields[field]}")) +
    content_tag('div', :style => 'position: absolute; left: -2000px;') {
      text_area_tag(field, '', :tabindex => '999', :rows => 2, :cols => 30)
    }
  end
  
  #TODO: Select, check_box, etc
end
