class PageHtmlPart < ActiveRecord::Base
  include TextileHelper
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  def before_save
    self.content_html = convert_textile_to_html(content)
  end
  
  def self.get_html_part(name)
    part = PageHtmlPart.find(:first, :conditions => ["name = ?", name])
    return "" if part.nil?          
    part.content_html
  end
  
end
