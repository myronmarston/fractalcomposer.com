require File.dirname(__FILE__) + '/../test_helper'

class GeneratedPieceTest < ActiveSupport::TestCase
  
  def test_required_fields
    piece = GeneratedPiece.new
    assert !piece.valid?
    
    [:user_ip_address, :fractal_piece, :generated_midi_file].each do |field|
      assert piece.errors.invalid?(field), "Field #{field} was not required as expected"
    end    
    
    fillin_generated_piece_values(piece) {|piece| assert piece.valid?}    
  end
   
end
