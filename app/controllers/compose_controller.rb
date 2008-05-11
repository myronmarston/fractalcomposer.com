require 'lib/FractalComposer.jar'
require 'lib/simple-xml-1.7.2.jar'
import com.myronmarston.util.ClassHelper
import com.myronmarston.music.settings.FractalPiece
import com.myronmarston.music.scales.Scale
import com.myronmarston.music.scales.ChromaticScale
import com.myronmarston.music.scales.MajorScale
import com.myronmarston.music.NoteName
import com.myronmarston.music.NoteStringParseException
import com.myronmarston.music.Instrument
import com.myronmarston.util.Fraction

class ComposeController < ApplicationController
  before_filter :load_fractal_piece_from_session
  after_filter :store_fractal_piece_in_session
  
  # this is the only action that supports a regular get rather than an XHR...
  def index      
    @scale_names = Hash.new    
    Scale::SCALE_TYPES.keySet.each do |type|    
      @scale_names[type.getSimpleName.titleize] = type
    end     

    @instrument_names = Instrument::AVAILABLE_INSTRUMENTS
  end
  
  def scale_selected_xhr    
    scale = get_scale(params[:scale], @fractal_piece.getScale.getKeyName.toString)
    @fractal_piece.setScale(scale)      
    render :partial => 'key_name_selection'    
  end
  
  def key_selected_xhr                    
    scale = get_scale(@fractal_piece.getScale.java_class, params[:key])
    @fractal_piece.setScale(scale)      
    render :nothing => true    
  end
  
  def set_germ_xhr    
    begin
      @fractal_piece.setGermString(params[:germ_string])
    rescue NoteStringParseException => ex
      @error_message = ex.message.sub(/[^:]*: /, '')
      render :partial => 'germ_string_error'
      return
    end    
    
    save_germ_to_midi_file
    render :partial => 'midi_player', :locals => {:midi_filename => @germ_filename, :div_id => 'germ_midi_player'}
  end

  def get_voice_sections_xhr      
    @tristate_options = {'Use Section Default' => nil, 'Yes' => true, 'No' => false}        
    @voices_or_sections_label = params[:voices_or_sections]
    @voice_or_section_index = params[:index]
    @voice_or_section = get_voice_or_section(@voices_or_sections_label, @voice_or_section_index)
    @fieldset_div_id = params[:fieldset_div_id] 
    @loading_div_id = params[:loading_div_id]
    respond_to do |format|
      format.js
    end
  end
  
  def add_voice_xhr    
    render :nothing => true
  end
    
  def generate_piece_xhr    
    # set our fractal piece options based on the params hash...    
    @fractal_piece.setScale(get_scale(params[:scale], params[:key]))
    @fractal_piece.setGermString(params[:germ_string])
    params[:voices].each_pair do |index, voice_settings|       
      voice = @fractal_piece.getVoices.get(index.to_i)
      voice.setInstrumentName(voice_settings[:instrument])
      voice.setOctaveAdjustment(voice_settings[:octave_adjustment].to_i)
      voice.setSpeedScaleFactor(Fraction.new(voice_settings[:speed_scale_factor]))      
    end
    
    save_piece_to_midi_file
    render :partial => 'midi_player', :locals => {:midi_filename => @piece_filename, :div_id => 'piece_midi_player'}
  end
  
  def finished_editing_tab_xhr
    if params.has_key?('voices') && params.has_key?('sections')
      logger.error("The params hash was expected to have either voices or sections, but it had both.")
      return
    elsif params.has_key?('voices')
      voices_or_sections = 'voices'
    elsif params.has_key?('sections')
      voices_or_sections = 'sections'
    else
      logger.error("The params hash was expected to have either voices or sections, but it had neither.")
      return
    end
      
    # iterate over all the voices or sections, as appropriate...
    params[voices_or_sections].each_pair do |voice_or_section_index, voice_or_section_hash|              
      next unless voice_or_section_hash.has_key?(:voice_sections)

      # dynamically get the voice or section
      voice_or_section = get_voice_or_section(voices_or_sections, voice_or_section_index)

      # iterate over the hash key/values for this voice or section...
      voice_or_section_hash[:voice_sections].each_pair do |voice_section_index, voice_section_hash|

        # get the particular voice section
        voice_section = voice_or_section.getVoiceSections.get(voice_section_index.to_i)

        # set the values.
        # we use eval for the combo box fields, because eval {boolean string} 
        # returns the proper value, and eval "" returns nil, which is the correct value.
        # for boolean values, the hash will only have the key if the box is 
        # checked, so we use has_key?          
        voice_section.setApplyInversion(eval(voice_section_hash[:apply_inversion]))          
        voice_section.setApplyRetrograde(eval(voice_section_hash[:apply_retrograde]))
        voice_section.setRest(voice_section_hash.has_key?(:rest))

        # self similarity settings are in another hash...
        if voice_section_hash.has_key?(:self_similarity_settings)
          self_similarity_settings_hash = voice_section_hash[:self_similarity_settings]
        else
          # provide an empty hash, as we will not have one if all three options
          # are set to false
          self_similarity_settings_hash = Hash.new
        end
        self_similarity_settings = voice_section.getSelfSimilaritySettings
        self_similarity_settings.setApplyToPitch(self_similarity_settings_hash.has_key?(:pitch))
        self_similarity_settings.setApplyToRhythm(self_similarity_settings_hash.has_key?(:rhythm))
        self_similarity_settings.setApplyToVolume(self_similarity_settings_hash.has_key?(:volume))
      end # end voice_sections hash loop
    end # end voices_or_sections hash loop

    render :nothing => true    
  end
  
  protected
  
  def save_germ_to_midi_file        
    @germ_filename = get_temp_midi_filename('germs')
    @fractal_piece.saveGermToMidiFile("public#{@germ_filename}")    
  end
  
  def save_piece_to_midi_file
    @piece_filename = get_temp_midi_filename('pieces')
    @fractal_piece.createAndSaveMidiFile("public#{@piece_filename}")    
  end
  
  def get_temp_midi_filename(subdirectory)
    require 'lib/uuidtools.rb'    
    "/temp/#{subdirectory}/#{UUID.random_create.to_s}.mid"
  end
  
  def get_voice_or_section(voices_or_sections_label, voice_or_section_index)    
    eval "@fractal_piece.get#{voices_or_sections_label.titleize}.get(#{voice_or_section_index})"
  end
  
  def get_scale(scale_class_name, key_name) 
    # TODO: what if the scale is chromatic and the key_name is blank?
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
    begin
      @fractal_piece = FractalPiece.loadFromXml(session[:fractal_piece]) if session[:fractal_piece]
    rescue NativeException => ex
      # if our serialization changes, we will get an exception. in this case, 
      # just log the error and start the fractal piece over
      logger.error("An error occurred while loading the fractal piece from the session: #{ex.message}")
    end
    
    if (@fractal_piece.nil?) 
      @fractal_piece = FractalPiece.new
      @fractal_piece.createDefaultSettings
    end
       
    if @fractal_piece.getGermString != '' 
      # we have a valid germ; make sure we have a midi file for it...      
      @germ_filename = session[:germ_filename] if session[:germ_filename] && File.exist?("/public#{session[:germ_filename]}")
      save_germ_to_midi_file unless @germ_filename
    end
  end

  def store_fractal_piece_in_session            
    session[:fractal_piece] = @fractal_piece.getXmlRepresentation if @fractal_piece     
    session[:germ_filename] = @germ_filename if @germ_filename
  end
  
end
