module PathHelper
  def get_url_filename(filename)
    # remove the "public/" from the front of the string, if it has it
    filename.gsub(/^public\//, '')
  end
  
  def get_local_filename(filename)
    # add public/ to the start of the string, unless it already has it
    "public/#{filename}" unless filename =~ /^public\//
  end    
  
  def sanitize_filename(filename)
    # replace everything except a-z, A-Z, 0-9 and / with an underscore...
    filename.gsub(/[^a-zA-Z0-9\/]+/, '_')
  end
end
