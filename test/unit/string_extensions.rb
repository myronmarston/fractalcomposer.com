$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'string_extensions'

class StringExtensions < Test::Unit::TestCase
  
  def test_is_int
    assert "98234".is_int?
    assert "-2342".is_int?
    assert "02342".is_int?
    assert !"+342".is_int?
    assert !"3-42".is_int?
    assert !"342.234".is_int?
    assert !"a342".is_int?
    assert !"342a".is_int?
  end
  
  def test_safe_to_i
    assert 234234 == 234234.safe_to_i
    assert 237 == "237".safe_to_i
    begin
      "a word".safe_to_i
      fail 'safe_to_i did not raise the expected error.'
    rescue NotAnIntError 
      # this is what we expect..
    end
  end
  
  def test_floats
    %w( 2342.34  00002342.34  0.34  .34  2.34  23.  23 
       +2342.34 +00002342.34 +0.34 +.34 +2.34 +23. +23 
       -2342.34 -00002342.34 -0.34 -.34 -2.34 -23. -23 ).each do |str| 
        assert str.is_float?, "'#{str}' did not return the proper value for is_float?"
        assert str.safe_to_f != "0".to_f, "'#{str}' did not return the proper value for safe_to_f"
    end
    
    %w( 0 0. .0 -0 -0. -.0 +0 +0. +.0 ).each do |str|
      assert str.is_float?, "'#{str}' did not return the proper value for is_float?"
      assert str.safe_to_f == 0.to_f, "'#{str}' did not return the proper value for safe_to_f"
    end
    
    %w( asdfads 23423.adsf adfa.23 . + - +. -. ).each do |str| 
      assert !str.is_float?, "'#{str}' did not return the proper value for is_float?"
      begin
        str.safe_to_f
        fail "safe_to_f did not raise the expected error for '#{str}'"
      rescue NotAFloatError
        # this is what we exepct...
      end
    end
  end
end
