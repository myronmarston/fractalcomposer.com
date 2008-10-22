require 'path_helper'
require 'uuidtools.rb'
require 'fileutils.rb'
require 'FractalComposer.jar'
require 'simple-xml-1.7.2.jar'
require 'gervill.jar'
require 'tritonus_mp3-0.3.6.jar'
require 'tritonus_remaining-0.3.6.jar'
require 'tritonus_share-0.3.6.jar'
import com.myronmarston.util.ClassHelper
import com.myronmarston.music.settings.FractalPiece
import com.myronmarston.music.scales.Scale
import com.myronmarston.music.scales.ChromaticScale
import com.myronmarston.music.scales.MajorScale
import com.myronmarston.music.NoteName
import com.myronmarston.music.OutputManager
import com.myronmarston.music.GermIsEmptyException
import com.myronmarston.music.NoteStringParseException
import com.myronmarston.music.Instrument
import com.myronmarston.util.Fraction
import com.myronmarston.music.settings.TimeSignature
import com.myronmarston.music.settings.InvalidTimeSignatureException
import java.lang.NumberFormatException

class GeneratedPiece < ActiveRecord::Base; end

class AddGermToGeneratedPiece < ActiveRecord::Migration
  
  def self.up        
    add_column :generated_pieces, :germ, :string, :length => 500, :null => false, :default => ''
    
    GeneratedPiece.find(:all).each do |piece|
      next if piece.fractal_piece.blank?
      
      fp = FractalPiece.loadFromXml(piece.fractal_piece.to_s)
      piece.update_attributes!(:germ => fp.getGermString)
    end    
  end

  def self.down
    remove_column :generated_pieces, :germ
  end
  
end
