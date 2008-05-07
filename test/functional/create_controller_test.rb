require File.dirname(__FILE__) + '/../test_helper'
require 'FractalComposer.jar'
require 'simple-xml-1.7.2.jar'
import com.myronmarston.music.settings.FractalPiece
import com.myronmarston.music.NoteName
import com.myronmarston.music.scales.MinorPentatonicScale
import com.myronmarston.music.scales.MajorPentatonicScale
import com.myronmarston.music.scales.ChromaticScale

class CreateControllerTest < ActionController::TestCase
  def test_scale_selection
    get :index    
    
    assert_response :success
    #put @response.body
    fractal_piece = get_fractal_piece
    assert_equal ChromaticScale.java_class, fractal_piece.getScale.java_class
    assert_equal NoteName::C, fractal_piece.getScale.getKeyName
    assert_select "div#scale_selection" do
      assert_select "select#scale > option", :minimum => 6 # at least 6 scale options
      assert_chromatic_key_selection      
    end
    
    # select a minor scale...
    xhr :post, :scale_selected, :scale => "com.myronmarston.music.scales.MinorPentatonicScale"
    assert_response :success
    fractal_piece = get_fractal_piece
    assert_equal MinorPentatonicScale.java_class, fractal_piece.getScale.java_class
    assert_equal NoteName::C, fractal_piece.getScale.getKeyName
    assert_minor_tonality_key_selection
    
    # select a different key...
    xhr :post, :key_selected, :key => "E"
    assert_response :success
    fractal_piece = get_fractal_piece
    assert_equal MinorPentatonicScale.java_class, fractal_piece.getScale.java_class
    assert_equal NoteName::E, fractal_piece.getScale.getKeyName    
    
    # switch to a major scale; the key name should still be E
    xhr :post, :scale_selected, :scale => "com.myronmarston.music.scales.MajorPentatonicScale"
    assert_response :success
    fractal_piece = get_fractal_piece
    assert_equal MajorPentatonicScale.java_class, fractal_piece.getScale.java_class
    assert_equal NoteName::E, fractal_piece.getScale.getKeyName
    assert_major_tonality_key_selection
    
    # select a key name that is only valid for major tonality...
    xhr :post, :key_selected, :key => "Cb"
    assert_response :success
    fractal_piece = get_fractal_piece
    assert_equal MajorPentatonicScale.java_class, fractal_piece.getScale.java_class
    assert_equal NoteName::Cb, fractal_piece.getScale.getKeyName 
    
    # switch to a minor scale; since Cb is invalid, it should revert to the default (A)
    xhr :post, :scale_selected, :scale => "com.myronmarston.music.scales.MinorPentatonicScale"
    assert_response :success
    fractal_piece = get_fractal_piece
    assert_equal MinorPentatonicScale.java_class, fractal_piece.getScale.java_class
    assert_equal NoteName::A, fractal_piece.getScale.getKeyName
    assert_minor_tonality_key_selection
    
    # switch back to chromatic scale; the key selection should disapper and the key name should revert to C
    xhr :post, :scale_selected, :scale => "com.myronmarston.music.scales.ChromaticScale"
    assert_response :success
    fractal_piece = get_fractal_piece
    assert_equal ChromaticScale.java_class, fractal_piece.getScale.java_class
    assert_equal NoteName::C, fractal_piece.getScale.getKeyName
    assert_chromatic_key_selection
  end
  
  def get_fractal_piece
    FractalPiece.loadFromXml(session[:fractal_piece])
  end
    
  def assert_key_selection(keys)
    assert_select "span#key_name_selection" do
      assert_select "select#key > option", :count => keys.size
      keys.each do |key|
        assert_select "option[value=#{key}]"
      end      
    end
  end
  
  def assert_chromatic_key_selection
    assert_key_selection(%w())
  end  
  
  def assert_minor_tonality_key_selection
    assert_key_selection(%w(Ab Eb Bb F C G D A E B F# C# G# D# A#))
  end
  
  def assert_major_tonality_key_selection
    assert_key_selection(%w(Cb Gb Db Ab Eb Bb F C G D A E B F# C#))
  end
end
