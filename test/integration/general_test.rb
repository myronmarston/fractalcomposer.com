require "#{File.dirname(__FILE__)}/../test_helper"
require 'FractalComposer.jar'
require 'simple-xml-1.7.2.jar'
import com.myronmarston.music.settings.FractalPiece
import com.myronmarston.music.NoteName
import com.myronmarston.music.scales.MinorPentatonicScale
import com.myronmarston.music.scales.MajorPentatonicScale
import com.myronmarston.music.scales.ChromaticScale

class GeneralTest < ActionController::IntegrationTest
#  def test_non_xhr_redirection
#    # todo: add every xml_http_request  method here...
#    ['scale_selected_xhr', 'set_germ_xhr', 'get_voice_sections_xhr',
#     'add_voice_or_section_xhr', 'delete_voice_or_section_xhr',
#     'generate_voice_xhr', 'finished_editing_tab_xhr', 'clear_session_xhr'
#     ].each do |action|
#      get '/compose'
#      assert_response :success
#      
#      post "/compose/#{action}"      
#      assert_redirected_to :controller => "compose", :action => "index"
#      follow_redirect!
#      assert_response :success
#    end
#  end
  
  def test_clear_session
    open_session do |session|
      get '/compose'
      assert_response :success
      assert_select 'textarea#germ_string', ''    
      assert_equal '', get_fractal_piece.getGermString
      
      xml_http_request :post, '/compose/set_germ_xhr', :germ_string => 'C4 D4 E4'
      assert_response :success      
      assert_equal 'C4 D4 E4', get_fractal_piece.getGermString
      
      get '/compose'
      assert_response :success
      assert_select 'textarea#germ_string', 'C4 D4 E4'
      
      xml_http_request :post, '/compose/clear_session_xhr'
      assert_response :success      
      assert_equal nil, get_fractal_piece
      
      get '/compose'
      assert_response :success
      assert_select 'textarea#germ_string', ''      
      assert_equal '', get_fractal_piece.getGermString
    end
  end
#  
#  def test_default_values
#    # test that we have the default values we expect
#    open_session do |session|
#      get '/compose'
#      assert_response :success
#      
#      # default scale: chromatic      
#      assert_select "select#scale > option[selected=selected][value$=ChromaticScale]"        
#            
#      # default time sig: 4/4
#      assert_select "input#time_signature[value=\"4/4\"]"
#      
#      # default tempo
#      assert_select "input#tempo[value=\"90\"]"
#      
#      #todo: other defaults
#    end
#  end
#  
#  def test_finished_editing_piece_settings_tab
#    
#  end
  
#  
#  def test_correct_scale_selected
#    open_session do |session|
#      # test that the correct scale option is selected, based on the which scale has
#      # been set in the fractal composer object...
#      xml_http_request :post, '/compose/scale_selected_xhr', :scale => "com.myronmarston.music.scales.MinorPentatonicScale"
#      assert_response :success
#      get '/compose'
#
#      assert_response :success
#      assert_select "p#scale_selection" do
#        assert_select "select#scale > option", :minimum => 6 # at least 6 scale options
#        assert_select "select#scale > option[selected=selected][value$=MinorPentatonicScale]"
#        assert_minor_tonality_key_selection      
#      end        
#    end    
#  end
#  
#  def test_scale_selection
#    open_session do |session|
#      get '/compose'
#      assert_response :success    
#      fractal_piece = get_fractal_piece
#      assert_equal ChromaticScale.java_class, fractal_piece.getScale.java_class
#      assert_equal NoteName::C, fractal_piece.getScale.getKeyName
#      assert_select "p#scale_selection" do
#        assert_select "select#scale > option", :minimum => 6 # at least 6 scale options
#        assert_select "select#scale > option[selected=selected][value$=ChromaticScale]"
#        assert_chromatic_key_selection      
#      end
#
#      # select a minor scale...
#      xml_http_request :post, '/compose/scale_selected_xhr', :scale => "com.myronmarston.music.scales.MinorPentatonicScale"
#      assert_response :success
#      fractal_piece = get_fractal_piece
#      assert_equal MinorPentatonicScale.java_class, fractal_piece.getScale.java_class
#      assert_equal NoteName::C, fractal_piece.getScale.getKeyName       
#      assert_minor_tonality_key_selection
#
#      # select a different key...
#      xml_http_request :post, '/compose/key_selected_xhr', :key => "E"
#      assert_response :success
#      fractal_piece = get_fractal_piece
#      assert_equal MinorPentatonicScale.java_class, fractal_piece.getScale.java_class
#      assert_equal NoteName::E, fractal_piece.getScale.getKeyName    
#
#      # switch to a major scale; the key name should still be E
#      xml_http_request :post, '/compose/scale_selected_xhr', :scale => "com.myronmarston.music.scales.MajorPentatonicScale"
#      assert_response :success
#      fractal_piece = get_fractal_piece
#      assert_equal MajorPentatonicScale.java_class, fractal_piece.getScale.java_class
#      assert_equal NoteName::E, fractal_piece.getScale.getKeyName
#      assert_major_tonality_key_selection
#
#      # select a key name that is only valid for major tonality...
#      xml_http_request :post, '/compose/key_selected_xhr', :key => "Cb"
#      assert_response :success
#      fractal_piece = get_fractal_piece
#      assert_equal MajorPentatonicScale.java_class, fractal_piece.getScale.java_class
#      assert_equal NoteName::Cb, fractal_piece.getScale.getKeyName 
#
#      # switch to a minor scale; since Cb is invalid, it should revert to the default (A)
#      xml_http_request :post, '/compose/scale_selected_xhr', :scale => "com.myronmarston.music.scales.MinorPentatonicScale"
#      assert_response :success
#      fractal_piece = get_fractal_piece
#      assert_equal MinorPentatonicScale.java_class, fractal_piece.getScale.java_class
#      assert_equal NoteName::A, fractal_piece.getScale.getKeyName
#      assert_minor_tonality_key_selection
#
#      # switch back to chromatic scale; the key selection should disapper and the key name should revert to C
#      xml_http_request :post, '/compose/scale_selected_xhr', :scale => "com.myronmarston.music.scales.ChromaticScale"
#      assert_response :success
#      fractal_piece = get_fractal_piece
#      assert_equal ChromaticScale.java_class, fractal_piece.getScale.java_class
#      assert_equal NoteName::C, fractal_piece.getScale.getKeyName
#      assert_chromatic_key_selection  
#    end    
#  end
#  
#  def test_set_germ_string
#    open_session do |session|
#      get '/compose'
#      assert_response :success 
#      assert_select "span#germ_midi_player_wrapper > span#germ_midi_player", "" # the midi player should be hidden since we don't have a germ...      
#            
#      xml_http_request :post, '/compose/set_germ_xhr', :germ_string => 'C4 D4 E4'
#      assert_response :success
#      fractal_piece = get_fractal_piece
#      assert_equal 'C4 D4 E4', fractal_piece.getGermString      
#      assert_select "object#germ_midi_player"
#    end
#  end
#  
#  def test_midi_player_present_if_germ_in_session
#    open_session do |session|
#      xml_http_request :post, '/compose/set_germ_xhr', :germ_string => 'C4 D4 E4'
#      assert_response :success
#      fractal_piece = get_fractal_piece
#      assert_equal 'C4 D4 E4', fractal_piece.getGermString
#      
#      get '/compose'
#      assert_response :success       
#      assert_select "object#germ_midi_player"
#    end
#  end
  
  def get_fractal_piece
    return nil if session.nil? || session[:fractal_piece].nil?
    FractalPiece.loadFromXml(session[:fractal_piece])
  end
    
  def assert_key_selection(keys)        
    assert_select "select#key > option", :count => keys.size
    keys.each do |key|
      assert_select "option[value=#{key}]"
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
