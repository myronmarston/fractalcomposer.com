require 'lib/FractalComposer.jar'
require 'lib/simple-xml-1.7.2.jar'
import com.myronmarston.util.ClassHelper
import com.myronmarston.music.settings.FractalPiece
import com.myronmarston.music.scales.Scale
import com.myronmarston.music.scales.ChromaticScale
import com.myronmarston.music.scales.MajorScale
import com.myronmarston.music.NoteName

class CreateController < ApplicationController
  before_filter :load_fractal_piece_from_session
  after_filter :store_fractal_piece_in_session
  
  def index      
    @scale_names = Hash.new    
    Scale::SCALE_TYPES.keySet.each do |type|    
      @scale_names[type.getSimpleName.titleize] = type
    end        
  end
  
  def scale_selected    
    if request.xhr?
      scale = get_scale(params[:scale], @fractal_piece.getScale.getKeyName.toString)
      @fractal_piece.setScale(scale)      
      render :partial => 'key_name_selection'
    end
  end
  
  def key_selected       
    if request.xhr?          
      scale = get_scale(@fractal_piece.getScale.java_class, params[:key])
      @fractal_piece.setScale(scale)      
      render :nothing => true
    end
  end
  
  protected
  
  def get_scale(scale_class_name, key_name) 
    # first, test that the key name is valid for this scale...    
    scale_class = eval("#{scale_class_name}.java_class")    
    valid_keys = Scale::SCALE_TYPES.get(scale_class)    
    if (valid_keys.contains(NoteName.getNoteName(key_name)))            
      return eval("#{scale_class_name}.new(NoteName.getNoteName(key_name))")
    else              
      return eval("#{scale_class_name}.new")
    end
  end
  
  def load_fractal_piece_from_session      
    @fractal_piece = FractalPiece.loadFromXml(session[:fractal_piece]) if session[:fractal_piece]
    @fractal_piece ||= FractalPiece.new    
  end

  def store_fractal_piece_in_session        
    session[:fractal_piece] = @fractal_piece.getXmlRepresentation if @fractal_piece     
  end
  
end
