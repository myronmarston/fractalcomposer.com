class PageHtmlPartsController < ApplicationController
  layout 'admin'
  active_scaffold :page_html_parts do |config|
      config.columns = [:name, :content]
      config.columns[:name].description = "The key used to identify this record."
      config.columns[:content].description = "<a href=""http://hobix.com/textile/"">Textile markup</a> that will be converted to html."
  end  
 
end