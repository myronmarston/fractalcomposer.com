class NotAnIntError < StandardError 
end

class String
  def is_int?    
    self =~ /^-?[0-9]+$/
  end
  
  def safe_to_i
    return self.to_i if is_int?
    raise NotAnIntError, 'The string is not a valid integer.', caller
  end
end

class Integer
  def safe_to_i
    return self
  end
end