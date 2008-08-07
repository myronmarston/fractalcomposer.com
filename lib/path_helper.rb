module PathHelper
  def get_url_filename(filename)
    return '' if filename.nil?
    if defined?($servlet_context)
      local_filename = get_local_filename(filename)
      raise "get_url_filename: it appears that a local file name was passed, and this method cannot handle it. #{filename}" if (local_filename == filename)
      filename
    else
      # remove the "public/" from the front of the string, if it has it
      filename.gsub(/^public\//, '')
    end    
  end
  
  def get_local_filename(filename)
    return '' if filename.nil?
    
    if defined?($servlet_context)      
      url_filename = get_url_filename(filename)
      local_filename = $servlet_context.getRealPath(filename)
      raise "get_local_filename: it appears that a url file name was passed, and this method cannot handle it. #{filename}" if (local_filename == url_filename)
      local_filename
    else
      # add public/ to the start of the string, unless it already has it
      filename_without_leading_slash = filename.gsub(/^\//, '')    
      filename_without_leading_slash.gsub(/^(?!public)/, 'public/')
    end    
  end    
  
  def sanitize_filename(filename)
    # replace everything except a-z, A-Z, 0-9 and / with an underscore...
    filename.gsub(/[^a-zA-Z0-9\/]+/, '_')
  end
end
