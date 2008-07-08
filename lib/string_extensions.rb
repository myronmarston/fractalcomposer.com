class NotAnIntError < StandardError 
end

class NotAFloatError < StandardError
end

class String
  def is_int?    
    self =~ /^-?[0-9]+$/
  end
  
  def safe_to_i
    return self.to_i if is_int?
    raise NotAnIntError, "The string '#{self}' is not a valid integer.", caller
  end
  
  def is_float?
    # the second regex is necesary to make sure we have at least one digit, to
    # disallow '.', '-', '+', '-.', etc.
    self =~ /^[+-]?\d*(\.\d*)?$/ && self =~ /\d+/
  end
  
  def safe_to_f
    return self.to_f if is_float?
    raise NotAFloatError, "The string '#{self}' is not a valid float.", caller
  end
end

class Integer
  def safe_to_i
    return self
  end
  
  def safe_to_f
    return self.to_f
  end
end

#TODO: Float class?