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
end
