module PathHelper
  def get_url_filename(filename)
    return '' if filename.nil?
    filename.sub(LOCAL_ROOT, '')
  end
  
  def get_full_url_filename(filename, request)
    File.join("#{request.protocol}#{request.host_with_port}", get_url_filename(filename))    
  end
  
  def get_local_filename(filename)
    return '' if filename.nil?
    
    return filename if filename.start_with? LOCAL_ROOT    
    File.join(LOCAL_ROOT, filename)      
  end    
  
  def sanitize_filename(filename)
    # replace everything except a-z, A-Z, 0-9 and / with an underscore...
    filename.gsub(/[^a-zA-Z0-9\/]+/, '_')
  end
end
