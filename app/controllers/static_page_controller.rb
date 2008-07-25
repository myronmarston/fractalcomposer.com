class StaticPageController < ApplicationController  
  
  def index
    render :text => PageHtmlPart.get_html_part(params[:name]), :layout => 'application'
  end
  
end
