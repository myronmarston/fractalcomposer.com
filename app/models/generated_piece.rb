require 'uuidtools.rb'
require 'path_helper'

class GeneratedPiece < ActiveRecord::Base
  extend PathHelper
  
  generate_validations  
  
  def generate_piece(fractal_piece, save)        
    self.fractal_piece = fractal_piece.getXmlRepresentation
    self.germ = fractal_piece.getGermString
    
    dir = "user_generated_files/generated_pieces/#{UUID.random_create.to_s}"
    Dir.mkdir(GeneratedPiece.get_local_filename(dir), 0755)
    self.generated_midi_file = GeneratedPiece.get_url_filename("#{dir}/piece.mid")
    self.generated_guido_file = GeneratedPiece.get_url_filename("#{dir}/piece.gmn")

    output_manager = fractal_piece.createPieceResultOutputManager    
    output_manager.saveMidiFile(GeneratedPiece.get_local_filename(self.generated_midi_file))
    output_manager.saveGuidoFile(GeneratedPiece.get_local_filename(self.generated_guido_file))    

    self.save! if save       
  end
  
  def self.random_germ
    distinct_count = find(:first, :select => 'COUNT(DISTINCT(germ)) AS count').count
    record = find(:first, :select => 'DISTINCT(germ) AS germ', :offset => rand(distinct_count))
    record.nil? ? '' : record.germ
  end
  
end
