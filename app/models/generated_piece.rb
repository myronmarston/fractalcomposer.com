require 'uuidtools.rb'
require 'path_helper'

class GeneratedPiece < ActiveRecord::Base
  extend PathHelper
  
  generate_validations  
  
  def generate_piece(fractal_piece, save)        
    self.fractal_piece = fractal_piece.getXmlRepresentation
    dir = "/generated_pieces/#{UUID.random_create.to_s}"
    Dir.mkdir(GeneratedPiece.get_local_filename(dir), 0755)
    self.generated_midi_file = GeneratedPiece.get_url_filename("#{dir}/piece.mid")
    self.generated_guido_file = GeneratedPiece.get_url_filename("#{dir}/piece.gmn")

    output_manager = fractal_piece.createPieceResultOutputManager    
    output_manager.saveMidiFile(GeneratedPiece.get_local_filename(self.generated_midi_file))
    output_manager.saveGuidoFile(GeneratedPiece.get_local_filename(self.generated_guido_file))    

    self.save! if save       
  end
  
end
