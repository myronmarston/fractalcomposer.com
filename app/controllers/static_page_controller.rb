class StaticPageController < ApplicationController  
  PAGES_WITH_HOME = STATIC_PAGES + ['home'] unless defined? PAGES_WITH_HOME
  
  def index
    page = params[:page].downcase
    if PAGES_WITH_HOME.include? page
      @page_title = page.titleize
      render :action => page
    else
      render :nothing => true, :status => 404 
    end        
  end
  
end
