require File.dirname(__FILE__) + '/../test_helper'
require 'FractalComposer.jar'
require 'simple-xml-1.7.2.jar'
import com.myronmarston.music.settings.FractalPiece
import com.myronmarston.util.FileHelper

class GeneratedPieceTest < ActiveSupport::TestCase
  
  def test_required_fields
    piece = GeneratedPiece.new
    assert !piece.valid?
    
    [:user_ip_address, :fractal_piece, :generated_midi_file].each do |field|
      assert piece.errors.invalid?(field), "Field #{field} was not required as expected"
    end    
        
    FileHelper.createAndUseTempFile 'test', 'mid', proc {|filename|      
        fp = FractalPiece.new
        fp.setGermString('G4 A4')
        fp.createDefaultSettings       
        fp.createPieceResultOutputManager.saveMidiFile(filename)
        
        piece.user_ip_address = '127.0.0.1'
        piece.fractal_piece = fp.getXmlRepresentation
        piece.generated_midi_file = filename
        
        assert piece.valid?
    }
  end
   
end
