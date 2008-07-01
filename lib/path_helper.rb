module PathHelper
  def get_url_filename(filename)
    return '' if filename.nil?
    
    # remove the "public/" from the front of the string, if it has it
    filename.gsub(/^public\//, '')
  end
  
  def get_local_filename(filename)
    return '' if filename.nil?
    
    # add public/ to the start of the string, unless it already has it
    filename_without_leading_slash = filename.gsub(/^\//, '')
    filename_without_leading_slash.gsub(/^(?!public)/, 'public/')
  end    
  
  def sanitize_filename(filename)
    # replace everything except a-z, A-Z, 0-9 and / with an underscore...
    filename.gsub(/[^a-zA-Z0-9\/]+/, '_')
  end
end
