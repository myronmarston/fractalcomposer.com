module PathHelper
  def get_url_filename(filename)
    return '' if filename.nil?
    
    # remove the "public/" from the front of the string, if it has it
    filename.gsub(/^public\//, '')
  end
  
  def get_local_filename(filename, include_leading_slash = false)
    return '' if filename.nil?
    
    # add public/ to the start of the string, unless it already has it
    filename_without_leading_slash = filename.gsub(/^\//, '')    
    with_public = filename_without_leading_slash.gsub(/^(?!public)/, 'public/')
    
    (include_leading_slash ? '/' + with_public : with_public)    
  end    
  
  def sanitize_filename(filename)
    # replace everything except a-z, A-Z, 0-9 and / with an underscore...
    filename.gsub(/[^a-zA-Z0-9\/]+/, '_')
  end
end
