require 'jruby'
java.lang.Thread.currentThread.setContextClassLoader(JRuby.runtime.jruby_class_loader)

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

#todo: validate all params before inserting it into code via eval or send to prevent injection attacks
#todo: use safe_to_i string method
class ComposeController < ApplicationController
  extend PathHelper
  
  # these filters persist @fractal_piece between requests; all actions need this
  before_filter :load_fractal_piece_from_session
  after_filter :store_fractal_piece_in_session
  
  # these filters set some variables used by particular actions...  
  before_filter :set_instrument_names, :only => [ :index, :add_voice_or_section_xhr, :clear_session_xhr ]
  before_filter :set_scale_names, :only => [ :index, :get_section_overriden_scale_xhr, :clear_session_xhr ]
    
  def index   
    # todo: if the user refreshes without tabbing off of the germ string, the text box contains
    # additional characters not found in the germ    
  end
  
  def listen_to_part_xhr
    update_fractal_piece
    part_type = params[:part_type]
    case part_type
      when 'voice', 'section'
        index = params[:index].safe_to_i
        part = get_voice_or_section(part_type.pluralize, index)
        @div_id_prefix = "#{part_type}_#{index}"
      when 'voice_section'
        voice_index = params[:voice_index].safe_to_i
        section_index = params[:section_index].safe_to_i
        part = @fractal_piece.getVoices.getByUniqueIndex(voice_index).getVoiceSections.getByOtherTypeUniqueIndex(section_index)
        @div_id_prefix = "voice_section_voice_#{voice_index}_section_#{section_index}"
      else
        raise "The part type (#{part_type}) is invalid."
    end
    
    @output_manager = part.createOutputManager
    local_dir = ComposeController.get_local_filename("#{get_temp_directory_for_session}")
    @output_manager.saveMidiFile("#{local_dir}/#{@div_id_prefix}.mid")
    @output_manager.saveGuidoFile("#{local_dir}/#{@div_id_prefix}.gmn")    
    
    respond_to { |format| format.js } 
  end
    
  def scale_selected_xhr
    @input_prefix = params[:input_prefix]
    @generate_update_germ_js = (params[:generate_update_germ_js] == 'true')
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
  
  def get_section_overriden_scale_xhr    
    @voices_or_sections_label = 'sections'
    @voice_or_section = get_voice_or_section(@voices_or_sections_label, params[:unique_index])
    @scale_content_wrap_id = params[:scale_content_wrap_id]
    # override the settings, first turning it to false if it's not already false.
    # this is necessary because we don't make an ajax call when the override is set 
    # to false, and the settings copy the scale when it is
    # set from false to true.  So, we want to make sure it is false before setting
    # it to true.
    @voice_or_section.setOverridePieceScale(false)    
    @voice_or_section.setOverridePieceScale(true)  
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
    #todo: this has errors after deleting a voice or section
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
  
  def submit_to_library_xhr    
    @user_submission = UserSubmission.new(params[:user_submission])
    @user_submission.generated_piece_id = session[:last_generated_piece_id]    
    @user_submission_saved = @user_submission.save
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
  
  def update_scale(object_to_update_scale_on, hash)
    if hash.has_key?(:scale) && hash.has_key?(:key)
      # set the scale to an instance variable so that we can access it from a partial...
      @scale = get_scale(object_to_update_scale_on.getScale, hash[:scale], hash[:key])
      object_to_update_scale_on.setScale(@scale) 
    end    
  end
  
  def update_fractal_piece    
    # set our fractal piece options based on the params hash...    
    update_scale(@fractal_piece, params)
    #@fractal_piece.setScale(get_scale(@fractal_piece.getScale, params[:scale], params[:key])) if params.has_key?(:scale) && params.has_key?(:key)
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
  
  def update_voice_or_section_common_settings(settings, settings_hash)    
    set_float_value(settings_hash, :volume_adjustment) {|f| settings.setVolumeAdjustment(f)}
    set_int_value(settings_hash, :scale_step_offset) {|i| settings.setScaleStepOffset(i)}
  end
  
  def update_voice(unique_voice_index, voice_hash)
    voice = @fractal_piece.getVoices.getByUniqueIndex(unique_voice_index.to_i)  
    
    voice.setInstrumentName(voice_hash[:instrument]) if voice_hash.has_key?(:instrument)   
    update_voice_settings(voice.getSettings, voice_hash[:voice_settings]) if voice_hash.has_key?(:voice_settings)
    
    update_voice_sections(voice.getVoiceSections, voice_hash[:voice_sections]) if voice_hash.has_key?(:voice_sections)
  end
  
  def update_voice_settings(voice_settings, voice_settings_hash)       
    # todo: validate the values before setting them...
    voice_settings.setOctaveAdjustment(voice_settings_hash[:octave_adjustment].to_i)
    voice_settings.setSpeedScaleFactor(Fraction.new(voice_settings_hash[:speed_scale_factor]))  
    
    update_voice_or_section_common_settings(voice_settings, voice_settings_hash)
    
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
        
    override_scale = section_hash.has_key?(:override_scale)    
    section.setOverridePieceScale(override_scale)            
    if override_scale
      update_scale(section, section_hash)
    end    
    
    update_section_settings(section.getSettings, section_hash[:section_settings]) if section_hash.has_key?(:section_settings)       
    update_voice_sections(section.getVoiceSections, section_hash[:voice_sections]) if section_hash.has_key?(:voice_sections)
  end       
  
  def update_section_settings(section_settings, section_settings_hash)
    section_settings.setApplyInversion(section_settings_hash.has_key?(:apply_inversion))
    section_settings.setApplyRetrograde(section_settings_hash.has_key?(:apply_retrograde))
    update_voice_or_section_common_settings(section_settings, section_settings_hash)
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
    @germ_guido_filename = nil    
  end
  
  def save_germ_files(save_midi, save_image)
    begin      
      @germ_midi_filename = get_germ_midi_filename
      @germ_guido_filename = get_germ_guido_filename    
      output_manager = @fractal_piece.createGermOutputManager    
      output_manager.saveMidiFile(ComposeController.get_local_filename(@germ_midi_filename)) if save_midi
      output_manager.saveGuidoFile(ComposeController.get_local_filename(@germ_guido_filename)) if save_image
    rescue GermIsEmptyException => ex
      logger.info "The germ could not be saved because the germ is empty."
      clear_germ_files
    end
  end
  
  def save_piece_files
    begin
      @last_generated_piece = GeneratedPiece.new
      @last_generated_piece.user_ip_address = request.remote_ip
      @last_generated_piece.generate_piece(@fractal_piece, true) # pass true to save
      
      # store the id so that we can retrieve it if the user submits the piece
      session[:last_generated_piece_id] = @last_generated_piece.id 
    rescue GermIsEmptyException => ex
      logger.info "The piece could not be saved because the germ is empty."      
    end    
  end
  
  def get_temp_directory_for_session    
    temp_dir = session[:session_temp_dir] || temp_dir = "/temp/dir_#{UUID.random_create.to_s}"
    
    # File.exist? also works on directories
    # mode 0755 is read/write/execute for the user who creates the file, 
    # and read/execute for everyone else
    Dir.mkdir(ComposeController.get_local_filename(temp_dir), 0755) unless File.exist?(ComposeController.get_local_filename(temp_dir)) 
    session[:session_temp_dir] = temp_dir
    return temp_dir
  end
  
  def delete_temp_directory_for_session
    temp_dir = session[:session_temp_dir]
    if temp_dir
      local_temp_dir = ComposeController.get_local_filename(temp_dir)      
      if File.exist?(local_temp_dir)
        FileUtils.remove_dir(local_temp_dir, true)
      end
    end
  end
  
  def delete_germ_files_for_session
    temp_dir = session[:session_temp_dir]
    if temp_dir        
      if File.exist?(ComposeController.get_local_filename(temp_dir))
        FileUtils.rm [ComposeController.get_local_filename(get_germ_midi_filename), 
                      ComposeController.get_local_filename(get_germ_guido_filename)], :force => true
      end
    end
  end
  
  def get_germ_midi_filename
    "#{get_temp_directory_for_session}/germ.mid"
  end
  
  def get_germ_guido_filename
    "#{get_temp_directory_for_session}/germ.gmn"
  end  
  
  def get_voice_or_section(voices_or_sections_label, unique_index)    
    @fractal_piece.send("get#{voices_or_sections_label.titleize}").getByUniqueIndex(unique_index.safe_to_i)    
  end
  
  def get_scale(existing_scale, scale_class_name, key_name)     
    # first, test that the key name is valid for this scale... 
    key_name = existing_scale.getKeyName.toString if key_name == ''        
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
      @germ_midi_filename = nil unless File.exists?(ComposeController.get_local_filename(@germ_midi_filename))      
      
      @germ_guido_filename = get_germ_guido_filename      
      @germ_guido_filename = nil unless File.exists?(ComposeController.get_local_filename(@germ_guido_filename))      
    end

  end

  def store_fractal_piece_in_session           
    session[:fractal_piece] = @fractal_piece.getXmlRepresentation if @fractal_piece         
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
    
  def set_float_value(hash, hash_key)
    begin
      yield hash[hash_key].safe_to_f if hash.has_key?(hash_key)
    rescue NotAFloatError => ex
      #TODO: this should rescue all errors.  What is the root error class?
      logger.error("An error occurred while setting the #{hash_key.to_s.titleize}: #{ex.message}")
    end
  end
  
  def set_int_value(hash, hash_key)
    begin
      yield hash[hash_key].safe_to_i if hash.has_key?(hash_key)
    rescue NotAnIntError => ex
      #TODO: this should resuce all errors.  What is the root error class?
      logger.error("An error occurred while setting the #{hash_key.to_s.titleize}: #{ex.message}")
    end
  end
   
end