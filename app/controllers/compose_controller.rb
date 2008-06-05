require 'lib/uuidtools.rb'
require 'fileutils.rb'
require 'lib/FractalComposer.jar'
require 'lib/simple-xml-1.7.2.jar'
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

#todo: refactor eval's to use send instead
class ComposeController < ApplicationController
  # these filters persist @fractal_piece between requests; all actions need this
  before_filter :load_fractal_piece_from_session
  after_filter :store_fractal_piece_in_session
  
  # update the fractal piece based on the request's params
  # this filter must come after load_fractal_piece_from_session
  #before_filter :update_fractal_piece
  
  # this filter sets our instrument_names variable; all actions that need it should be included.
  before_filter :set_instrument_names, :only => [ :index, :add_voice_or_section_xhr, :clear_session_xhr ]
  before_filter :set_scale_names, :only => [ :index, :clear_session_xhr ]
  
  # this is the only action that supports a regular get rather than an XHR...
  def index   
    # todo: if the user refreshes without tabbing off of the germ string, the text box contains
    # additional characters not found in the germ    
  end
  
  def scale_selected_xhr
    @update_germ = (params[:update_germ] == 'true')
    update_fractal_piece
    save_germ_files(false, @update_germ)
    respond_to { |format| format.js }    
  end
  
  def set_time_signature_xhr
    @update_germ = (params[:update_germ] == 'true')
    update_fractal_piece
    save_germ_files(false, @update_germ)
    respond_to { |format| format.js }
  end
  
  def set_germ_xhr        
    update_germ(true, params[:germ_string])    
    respond_to { |format| format.js } 
  end

  def get_voice_sections_xhr      
    @voice_or_section_div_id = params[:voice_or_section_div_id]
    @voices_or_sections_label = params[:voices_or_sections]    
    @voice_or_section = get_voice_or_section(@voices_or_sections_label, params[:unique_index])
    @fieldset_div_id = params[:fieldset_div_id] 
    @loading_div_id = params[:loading_div_id]
    respond_to { |format| format.js }    
  end
  
  def get_voice_section_overriden_settings_xhr
    update_fractal_piece # update or voice or section settings, so we can clone them if need be... 
    @settings_type = params[:settings_type]
    @settings_content_wrap_id = params[:settings_content_wrap_id]
    @voices_or_sections_label = params[:voices_or_sections]    
    @voice_or_section = get_voice_or_section(@voices_or_sections_label, params[:main_unique_index])
    @voice_section = @voice_or_section.getVoiceSections.getByOtherTypeUniqueIndex(params[:other_unique_index].to_i)
    
    # override the settings, first turning it to false if it's not already false.
    # this is necessary because we don't make an ajax call when the override is set 
    # to false, and the settings copy the voice or section settings when it is
    # set from false to true.  So, we want to make sure it is false before setting
    # it to true.
    @voice_section.send("setOverride#{@settings_type}Settings", false)    
    @voice_section.send("setOverride#{@settings_type}Settings", true)    
    
    @settings = @voice_section.send("get#{@settings_type}Settings")
    respond_to { |format| format.js } 
  end
  
  def add_voice_or_section_xhr     
    @singular_voices_or_sections_label = params[:voice_or_section]    
    @voices_or_sections_label = @singular_voices_or_sections_label.pluralize        
    @voice_or_section = @fractal_piece.send("create#{@singular_voices_or_sections_label.titleize}")    
    respond_to { |format| format.js }    
  end
  
  def delete_voice_or_section_xhr      
    voices_or_sections = @fractal_piece.send("get#{params[:voice_or_section].pluralize.titleize}")
    voices_or_sections.removeByUniqueIndex(params[:unique_index].to_i)    
    render :nothing => true
  end
    
  def generate_piece_xhr    
    update_fractal_piece
    save_piece_files
    respond_to { |format| format.js }
  end
  
  def finished_editing_tab_xhr     
    update_fractal_piece
    render :nothing => true    
  end
  
  def clear_session_xhr    
    delete_temp_directory_for_session
    reset_session
    @fractal_piece = get_new_fractal_piece     
    clear_germ_files
    respond_to { |format| format.js } 
  end
  
  protected
  
  def update_germ(save_files, germ_string) 
    logger.info "germ string = #{germ_string}"
    session[:germ_string] = germ_string
    begin
      @fractal_piece.setGermString(germ_string)
      save_germ_files(true, true) if save_files
      session[:germ_error_message] = nil
    rescue NoteStringParseException => ex      
      session[:germ_error_message] = ex.message.sub(/[^:]*: /, '')      
      clear_germ_files
    end
  end  
  
  def update_fractal_piece    
    # set our fractal piece options based on the params hash...    
    @fractal_piece.setScale(get_scale(params[:scale], params[:key])) if params.has_key?(:scale) && params.has_key?(:key)
    @fractal_piece.setGenerateLayeredIntro(params.has_key?(:generate_layered_intro))
    @fractal_piece.setGenerateLayeredOutro(params.has_key?(:generate_layered_outro))
    
    update_germ(false, params[:germ_string]) if params.has_key?(:germ_string)

    begin
      @fractal_piece.setTimeSignature(TimeSignature.new(params[:time_signature])) if params.has_key?(:time_signature)
    rescue InvalidTimeSignatureException => ex
      logger.error("An error occurred while parsing the time signature string: #{ex.message}")
    end
    
    begin
      @fractal_piece.setTempo(java.lang.Integer.parseInt(params[:tempo])) if params.has_key?(:tempo)
    rescue NumberFormatException => ex
      logger.error("An error occurred while parsing the tempo string: #{ex.message}")
    end
            
    {:voices => :update_voice, :sections => :update_section}.each_pair do |voices_or_sections_label, method_name|
      if params.has_key?(voices_or_sections_label)
        params[voices_or_sections_label].each_pair do |unique_voice_or_section_index, voice_or_section_hash|              
          self.send(method_name, unique_voice_or_section_index, voice_or_section_hash)        
        end
      end
    end
  end
  
  def update_voice(unique_voice_index, voice_hash)
    voice = @fractal_piece.getVoices.getByUniqueIndex(unique_voice_index.to_i)  
    
    voice.setInstrumentName(voice_hash[:instrument])    
    update_voice_settings(voice.getSettings, voice_hash[:voice_settings])
    
    update_voice_sections(voice.getVoiceSections, voice_hash[:voice_sections]) if voice_hash.has_key?(:voice_sections)
  end
  
  def update_voice_settings(voice_settings, voice_settings_hash)       
    # todo: validate the values before setting them...
    voice_settings.setOctaveAdjustment(voice_settings_hash[:octave_adjustment].to_i)
    voice_settings.setSpeedScaleFactor(Fraction.new(voice_settings_hash[:speed_scale_factor]))  
    
    # self similarity settings are in another hash...
    self_similarity_settings_hash = voice_settings_hash[:self_similarity_settings]
    self_similarity_settings = voice_settings.getSelfSimilaritySettings
    self_similarity_settings.setSelfSimilarityIterations(self_similarity_settings_hash[:self_similarity_iterations].to_i)
    self_similarity_settings.setApplyToPitch(self_similarity_settings_hash.has_key?(:pitch))
    self_similarity_settings.setApplyToRhythm(self_similarity_settings_hash.has_key?(:rhythm))
    self_similarity_settings.setApplyToVolume(self_similarity_settings_hash.has_key?(:volume))
  end
  
  def update_section(unique_section_index, section_hash)
    section = @fractal_piece.getSections.getByUniqueIndex(unique_section_index.to_i)    
    
    # todo: update the scale...
    update_section_settings(section.getSettings, section_hash[:section_settings])        
    update_voice_sections(section.getVoiceSections, section_hash[:voice_sections]) if section_hash.has_key?(:voice_sections)
  end       
  
  def update_section_settings(section_settings, section_settings_hash)
    section_settings.setApplyInversion(section_settings_hash.has_key?(:apply_inversion))
    section_settings.setApplyRetrograde(section_settings_hash.has_key?(:apply_retrograde))
  end
  
  def update_voice_sections(voice_sections, voice_sections_hash)
    return if voice_sections_hash == Hash.new.default
    
    # iterate over the hash key/values for this voice or section...    
    voice_sections_hash.each_pair do |voice_section_other_type_unique_index, voice_section_hash|
      # get the particular voice section
      voice_section = voice_sections.getByOtherTypeUniqueIndex(voice_section_other_type_unique_index.to_i)

      # set the values.
      # for boolean values, the hash will only have the key if the box is checked, so we use has_key?  
      voice_section.setRest(voice_section_hash.has_key?(:rest))
      
      override_voice_settings = voice_section_hash.has_key?(:override_voice_settings)      
      voice_section.setOverrideVoiceSettings(override_voice_settings) unless override_voice_settings == voice_section.getOverrideVoiceSettings
      update_voice_settings(voice_section.getVoiceSettings, voice_section_hash[:voice_settings]) if override_voice_settings
      
      override_section_settings = voice_section_hash.has_key?(:override_section_settings)
      voice_section.setOverrideSectionSettings(override_section_settings) unless override_section_settings == voice_section.getOverrideSectionSettings
      update_section_settings(voice_section.getSectionSettings, voice_section_hash[:section_settings]) if override_section_settings
    end
  end
  
  def clear_germ_files
    delete_germ_files_for_session
    @germ_midi_filename = nil
    @germ_image_filename = nil    
  end
  
  def save_germ_files(save_midi, save_image)
    begin
      @germ_midi_filename = get_germ_midi_filename
      @germ_image_filename = get_germ_image_filename    
      output_manager = @fractal_piece.createGermOutputManager    
      output_manager.saveMidiFile(get_local_filename(@germ_midi_filename)) if save_midi
      output_manager.saveGifImage(get_local_filename(@germ_image_filename)) if save_image
    rescue GermIsEmptyException => ex
      logger.info "The germ could not be saved because the germ is empty."
      clear_germ_files
    end
  end
  
  def save_piece_files
    begin
      @piece_midi_filename = get_piece_midi_filename            
      @piece_image_filename = get_piece_image_filename    
      output_manager = @fractal_piece.createPieceResultOutputManager    
      output_manager.saveMidiFile(get_local_filename(@piece_midi_filename))
      output_manager.saveGifImage(get_local_filename(@piece_image_filename))
    rescue GermIsEmptyException => ex
      logger.info "The piece could not be saved because the germ is empty."
      @piece_midi_filename = nil    
      @piece_image_filename = nil
    end    
  end
  
  def get_temp_directory_for_session    
    temp_dir = session[:session_temp_dir] || temp_dir = "/temp/dir_#{UUID.random_create.to_s}"
    
    # File.exist? also works on directories
    # mode 0755 is read/write/execute for the user who creates the file, 
    # and read/execute for everyone else
    Dir.mkdir(get_local_filename(temp_dir), 0755) unless File.exist?(get_local_filename(temp_dir)) 
    session[:session_temp_dir] = temp_dir
    return temp_dir
  end
  
  def delete_temp_directory_for_session
    temp_dir = session[:session_temp_dir]
    if temp_dir
      local_temp_dir = get_local_filename(temp_dir)      
      if File.exist?(local_temp_dir)
        FileUtils.remove_dir(local_temp_dir, true)
      end
    end
  end
  
  def delete_germ_files_for_session
    temp_dir = session[:session_temp_dir]
    if temp_dir        
      if File.exist?(get_local_filename(temp_dir))
        FileUtils.rm [get_local_filename(get_germ_midi_filename), get_local_filename(get_germ_image_filename)], :force => true
      end
    end
  end
  
  def get_url_filename(filename)
    # remove the "public/" from the front of the string, if it has it
    filename.gsub(/^public\//, '')
  end
  
  def get_local_filename(filename)
    # add public/ to the start of the string, unless it already has it
    "public/#{filename}" unless filename =~ /^public\//
  end
  
  def get_germ_midi_filename
    "#{get_temp_directory_for_session}/germ.mid"
  end
  
  def get_germ_image_filename
    "#{get_temp_directory_for_session}/germ.gif"
  end  
  
  def get_piece_midi_filename
    "#{get_temp_directory_for_session}/generated_piece.mid"
  end
  
  def get_piece_image_filename
    "#{get_temp_directory_for_session}/generated_piece.gif"
  end
  
  def get_voice_or_section(voices_or_sections_label, unique_index)    
    @fractal_piece.send("get#{voices_or_sections_label.titleize}").getByUniqueIndex(unique_index.to_i)    
  end
  
  def get_scale(scale_class_name, key_name)     
    # first, test that the key name is valid for this scale... 
    key_name = @fractal_piece.getScale.getKeyName.toString if key_name == ''        
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
    
    @fractal_piece = get_new_fractal_piece if @fractal_piece.nil?      
    
    if @fractal_piece.getGerm.size > 0
      # we have a valid germ; set our instance variables if the files exist
      if (session[:germ_string].nil?)
        update_germ(false, params[:germ_string] || @fractal_piece.getGermString)
      end
      
      @germ_midi_filename = get_germ_midi_filename
      @germ_midi_filename = nil unless File.exists?(get_local_filename(@germ_midi_filename))
      
      @germ_image_filename = get_germ_image_filename
      @germ_image_filename = nil unless File.exists?(get_local_filename(@germ_image_filename))
    end

  end

  def store_fractal_piece_in_session           
    session[:fractal_piece] = @fractal_piece.getXmlRepresentation if @fractal_piece     
    session[:germ_filename] = @germ_filename if @germ_filename
  end
  
  def get_new_fractal_piece
    fractal_piece = FractalPiece.new
    fractal_piece.createDefaultSettings
    return fractal_piece
  end
  
  def set_instrument_names
    @instrument_names = Instrument::AVAILABLE_INSTRUMENTS
  end
  
  def set_scale_names
    @scale_names = Hash.new    
    Scale::SCALE_TYPES.keySet.each do |type|    
      @scale_names[type.getSimpleName.titleize] = type
    end  
  end
  
end
