# Load RedCloth if available
begin require 'redcloth' rescue nil end

module TextileHelper
  def convert_textile_to_html(textile_content)
    textile_content = "" if textile_content.nil?
    return RedCloth.new(textile_content).to_html(:textile)
  end    
end
