#TODO: passing a user_submission_id doesn't work quite right. it appears that more session variables are being cached and reused from the previously used fractal piece
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
  
  ALREADY_SUBMITTED_MSG = 'This piece has already been submitted to the library.' unless defined? ALREADY_SUBMITTED_MSG
  
  # these filters persist @fractal_piece between requests; all actions need this
  before_filter :load_fractal_piece_from_session
  after_filter :store_fractal_piece_in_session
  
  # these filters set some variables used by particular actions...  
  before_filter :set_instrument_names, :only => [ :index, :add_voice_or_section_xhr, :clear_session_xhr ]
  before_filter :set_scale_names, :only => [ :index, :get_section_overriden_scale_xhr, :clear_session_xhr ]
    
  def index     
  end
    
  def listen_to_part_xhr
    update_fractal_piece
    part_type = params[:part_type]
    case part_type
      when 'voice', 'section'
        index = params[:index].safe_to_i
        @output_manager = get_voice_or_section(part_type.pluralize, index).createOutputManager
        @div_id_prefix = "#{part_type}_#{index}"
      when 'voice_section'
        voice_index = params[:voice_index].safe_to_i
        section_index = params[:section_index].safe_to_i
        @output_manager = @fractal_piece.getVoices.getByUniqueIndex(voice_index).getVoiceSections.getByOtherTypeUniqueIndex(section_index).createOutputManager
        @div_id_prefix = "voice_section_voice_#{voice_index}_section_#{section_index}"
      when 'germ'
        @output_manager = @fractal_piece.createGermOutputManager
        @div_id_prefix = 'germ'
      else
        raise "The part type (#{part_type}) is invalid."
    end
        
    local_dir = ComposeController.get_local_filename(get_temp_directory_for_session)
    @output_manager.saveMidiFile("#{local_dir}/#{@div_id_prefix}.mid")
    @output_manager.saveGuidoFile("#{local_dir}/#{@div_id_prefix}.gmn")    
    
    respond_to { |format| format.js } 
  end
    
  def scale_selected_xhr
    @input_prefix = params[:input_prefix]    
    update_fractal_piece    
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
    @override_checkbox_id = params[:override_checkbox_id]
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
    # TODO: can this be combined with listen_to_part_xhr
    update_fractal_piece         
    save_piece_files unless get_last_generated_piece_fractal_piece_xml == current_piece_xml
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
    #TODO: this doesn't seem to clear everything out, such as last generated piece
    respond_to { |format| format.js } 
  end
  
  def open_submit_to_library_form_xhr
    update_fractal_piece    
    @last_generated_fractal_piece_xml = get_last_generated_piece_fractal_piece_xml
    current_piece_xml #fetch the xml into an instance variable
    @piece_already_submitted = current_piece_already_submitted?
    respond_to { |format| format.js } 
  end
  
  def submit_to_library_xhr    
    @piece_already_submitted = current_piece_already_submitted?
    
    unless @piece_already_submitted
      @user_submission = UserSubmission.new(params[:user_submission])
      @user_submission.generated_piece_id = session[:last_generated_piece_id]    
      @user_submission_saved = @user_submission.save

      add_previously_submitted_piece_to_session(@user_submission.generated_piece_id) if @user_submission_saved          
    end    
    
    respond_to { |format| format.js }
  end  
        
  protected
  
  def add_previously_submitted_piece_to_session(generated_piece_id)
    puts "add_previously_submitted_piece_to_session begin: #{session[:previously_submitted_pieces].inspect}"
    session[:previously_submitted_pieces] ||= Array.new
    session[:previously_submitted_pieces] << generated_piece_id unless session[:previously_submitted_pieces].include? generated_piece_id
    puts "add_previously_submitted_piece_to_session end: #{session[:previously_submitted_pieces].inspect}"
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
    
    set_string_value(params, :germ) {|val| @fractal_piece.setGermString(val)}
    set_string_value(params, :time_signature) {|val| @fractal_piece.setTimeSignature(TimeSignature.new(val))}
    set_int_value(params, :tempo) {|val| @fractal_piece.setTempo(val)}
                
    {:voices => :update_voice, :sections => :update_section}.each_pair do |voices_or_sections_label, method_name|
      if params.has_key?(voices_or_sections_label)
        params[voices_or_sections_label].each_pair do |unique_voice_or_section_index, voice_or_section_hash|              
          self.send(method_name, unique_voice_or_section_index, voice_or_section_hash)        
        end
      end
    end
  end
  
  def update_voice_or_section_common_settings(settings, settings_hash)        
    set_string_value(settings_hash, :volume_adjustment) {|f| settings.setVolumeAdjustment(Fraction.new(f))}
    set_int_value(settings_hash, :scale_step_offset) {|i| settings.setScaleStepOffset(i)}
    set_int_value(settings_hash, :octave_adjustment) {|val| settings.setOctaveAdjustment(val)}
    set_string_value(settings_hash, :speed_scale_factor) {|val| settings.setSpeedScaleFactor(Fraction.new(val))}        
  end
  
  def update_voice(unique_voice_index, voice_hash)
    voice = @fractal_piece.getVoices.getByUniqueIndex(unique_voice_index.to_i)  
    
    set_string_value(voice_hash, :instrument) {|val| voice.setInstrumentName(val)}
    
    update_voice_settings(voice.getSettings, voice_hash[:voice_settings]) if voice_hash.has_key?(:voice_settings)
    
    update_voice_sections(voice.getVoiceSections, voice_hash[:voice_sections]) if voice_hash.has_key?(:voice_sections)
  end
  
  def update_voice_settings(voice_settings, voice_settings_hash)       
    
    update_voice_or_section_common_settings(voice_settings, voice_settings_hash)
    
    # self similarity settings are in another hash...
    if voice_settings_hash.has_key?(:self_similarity_settings)
      self_similarity_settings_hash = voice_settings_hash[:self_similarity_settings]
      self_similarity_settings = voice_settings.getSelfSimilaritySettings
      
      set_int_value(self_similarity_settings_hash, :self_similarity_iterations) {|val| self_similarity_settings.setSelfSimilarityIterations(val)}      
      self_similarity_settings.setApplyToPitch(self_similarity_settings_hash.has_key?(:pitch))
      self_similarity_settings.setApplyToRhythm(self_similarity_settings_hash.has_key?(:rhythm))
      self_similarity_settings.setApplyToVolume(self_similarity_settings_hash.has_key?(:volume))
    end    
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
  
  def current_piece_xml
    @current_fractal_piece_xml ||= @fractal_piece.getXmlRepresentation           
  end
  
  def current_piece_already_submitted?
    current_xml = current_piece_xml
    
    (session[:previously_submitted_pieces] || []).each do |previous_piece_id|
      previous_piece = GeneratedPiece.find(previous_piece_id)
      return true if previous_piece.fractal_piece == current_xml
    end
    
    return false
  end
  
  def get_last_generated_piece_fractal_piece_xml
    id = session[:last_generated_piece_id]
    return '' unless id
    begin
      @last_generated_piece = GeneratedPiece.find(id)
    rescue ActiveRecord::RecordNotFound
      return ''
    end
    
    return @last_generated_piece.fractal_piece
  end
  
  def get_temp_directory_for_session    
    temp_dir = session[:session_temp_dir] || temp_dir = "/user_generated_files/temp/#{UUID.random_create.to_s}"
    
    # File.exist? also works on directories
    # mode 0755 is read/write/execute for the user who creates the file, 
    # and read/execute for everyone else
    local_temp_dir = ComposeController.get_local_filename(temp_dir)
    Dir.mkdir(local_temp_dir, 0755) unless File.exist?(local_temp_dir) 
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
      # first, check to see if the user is trying to work with an existing user submitted piece...
      if params.has_key?(:user_submission_id)
        begin
          user_sub = UserSubmission.find(params[:user_submission_id])
          piece_xml = user_sub.generated_piece.fractal_piece
          add_previously_submitted_piece_to_session(user_sub.generated_piece_id)
        rescue ActiveRecord::RecordNotFound      
          # bad id parameter, just ignore and we'll default to using the piece in the session or create a new one
        end        
      end
      
      piece_xml ||= session[:fractal_piece] if session[:fractal_piece]
      
      @fractal_piece = FractalPiece.loadFromXml(piece_xml) if piece_xml && piece_xml != ''
    rescue NativeException => ex
      # if our serialization changes, we will get an exception. in this case, 
      # just log the error and start the fractal piece over      
      logger.error("An error occurred while loading the fractal piece from the session: #{ex.message}")
    end
    
    @fractal_piece ||= get_new_fractal_piece    
  end

  def store_fractal_piece_in_session           
    session[:fractal_piece] = current_piece_xml if @fractal_piece         
  end
  
  def get_new_fractal_piece
    fractal_piece = FractalPiece.new
    fractal_piece.createDefaultSettings
    return fractal_piece
  end
  
  def set_instrument_names
    @instrument_names = Instrument::AVAILABLE_INSTRUMENTS.collect {|i| i.titleize}
  end
  
  def set_scale_names
    @scale_names = Hash.new    
    Scale::SCALE_TYPES.keySet.each do |type|    
      @scale_names[type.getSimpleName.titleize] = type.to_s.gsub(/class /, '')
    end  
  end
    
  def set_float_value(hash, hash_key)
    begin
      yield hash[hash_key].safe_to_f if hash.has_key?(hash_key)
    rescue Exception => ex
      #TODO: this should rescue all errors.  What is the root error class?
      logger.error("An error occurred while setting the #{hash_key.to_s.titleize}: #{ex.message}")
    end
  end
  
  def set_int_value(hash, hash_key)
    begin
      yield hash[hash_key].safe_to_i if hash.has_key?(hash_key)
    rescue Exception => ex
      #TODO: this should resuce all errors.  What is the root error class?
      logger.error("An error occurred while setting the #{hash_key.to_s.titleize}: #{ex.message}")
    end
  end
  
  def set_string_value(hash, hash_key)
    begin
      yield hash[hash_key].to_s if hash.has_key?(hash_key)
    rescue Exception => ex     
      logger.error("An error occurred while setting the #{hash_key.to_s.titleize}: #{ex.message}")
    end
  end
   
end
