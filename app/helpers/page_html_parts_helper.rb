module PageHtmlPartsHelper
  def content_form_column(record, input_name)
    text_area :record, :content, :cols => 80, :rows => 20
  end  
  
  def content_column(record)
    record.content_html
  end
end
