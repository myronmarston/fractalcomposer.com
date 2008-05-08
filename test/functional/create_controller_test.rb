require File.dirname(__FILE__) + '/../test_helper'

class CreateControllerTest < ActionController::TestCase
  
  def test_routings
    assert_routing("/create", :controller => "create", :action => "index")        
  end
  
  def test_bad_germ_string
    xhr :post, :set_germ_xhr, :germ_string => 'C4 D4 asdf4'
    assert_response :success
    fractal_piece = get_fractal_piece
    assert_equal '', fractal_piece.getGermString      
    assert_select "div.germ_string_error"
  end
      
  def get_fractal_piece
    FractalPiece.loadFromXml(session[:fractal_piece])
  end  
end