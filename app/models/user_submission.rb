require 'fileutils.rb'
require 'FractalComposer.jar'
require 'simple-xml-1.7.2.jar'
require 'gervill.jar'
require 'tritonus_mp3-0.3.6.jar'
require 'tritonus_remaining-0.3.6.jar'
require 'tritonus_share-0.3.6.jar'
require 'path_helper'
    
class UserSubmission < ActiveRecord::Base
  extend PathHelper  
  
  GENERATED_IMAGE_WIDTH = 450 unless defined? GENERATED_IMAGE_WIDTH
  
  acts_as_rated :rater_class => 'IpAddress', :rating_range => 1..5  
  acts_as_commentable    
      
  generate_validations
  validates_email_format_of :email
  
  #TODO: remove the url validation, but make sure that XSS can't happen....
  validates_http_url :website 
  attr_accessor :is_website_tester  
  
  def before_validation
    return if self.is_website_tester
    return if self.website.nil? || self.website == '' 
    
    #add the "http://" if it is an invalid website and that would make it valid...
    test_user_submission = UserSubmission.new
    test_user_submission.is_website_tester = true
    test_user_submission.website = self.website
    if !test_user_submission.valid? && test_user_submission.errors.invalid?(:website)
      test_user_submission.website = "http://#{test_user_submission.website}"
      
      test_user_submission.valid?
      if !test_user_submission.errors.invalid?(:website)
        self.website = test_user_submission.website
      end
    end
  end 
  
  def after_create        
    UserSubmissionProcessor.start_processor_if_necessary
  end
  
  def process
    self.update_attribute(:processing_began, Time.now)    
    generated_piece = self.generated_piece    
        
    fractal_piece = com.myronmarston.music.settings.FractalPiece.loadFromXml(generated_piece.fractal_piece)
    piece_output_manager = fractal_piece.createPieceResultOutputManager    
    germ_output_manager = fractal_piece.createGermOutputManager
    
    process_save_file('.mp3', :piece_mp3_file) {|f| piece_output_manager.saveMp3File(f)}
    process_save_file('.pdf', :piece_pdf_file) {|f| piece_output_manager.savePdfFile(f, self.title, self.name)}
    process_save_file('.png', :piece_image_file) {|f| piece_output_manager.savePngFile(f, self.title, self.name, GENERATED_IMAGE_WIDTH)}
    process_save_file('_germ.mp3', :germ_mp3_file) {|f| germ_output_manager.saveMp3File(f)}
    process_save_file('_germ.png', :germ_image_file) {|f| germ_output_manager.savePngFile(f, GENERATED_IMAGE_WIDTH)}
        
    self.update_attribute(:processing_completed, Time.now)    
  end
    
  def rating_width
    # each star image, including margins is 30 pixels wide.
    # however, the star itself is only 18 pixels wide, with a 6 pixel margin on each side
    rating = self.rating_average
    return nil unless rating
    int_part = rating.to_i
    fractional_part = rating - int_part
    
    width_for_int_part = (int_part * 30) 
    return width_for_int_part if fractional_part == 0
    return width_for_int_part + 6 + (fractional_part * 18).to_i
  end
  
  def page_view(ip_address)
    UserSubmission.increment_counter(:total_page_views, self.id)    
    UserSubmissionUniquePageView.page_view(self, ip_address)               
  end
  
  def processed?
    processed = self.processing_completed                 &&      
      user_submission_file_exists?(self.germ_image_file)  && 
      user_submission_file_exists?(self.germ_mp3_file)    && 
      user_submission_file_exists?(self.piece_image_file) && 
      user_submission_file_exists?(self.piece_mp3_file)   && 
      user_submission_file_exists?(self.piece_pdf_file)
    
    unless processed
      # the user submission processor only processes records with 'NULL' for processing_completed,
      # so make sure it's null, and make sure the processor is started...
    
      self.update_attribute(:processing_completed, nil)
      UserSubmissionProcessor.start_processor_if_necessary
    end
    
    return processed
  end
    
  private
  
  def user_submission_file_exists?(filename)
    filename = filename.to_s
    filename = UserSubmission.get_local_filename(filename)
    return File.exist?(filename) && File.file?(filename)
  end
  
  def process_save_file(extension, field)
    filename = get_base_filename + extension
    yield UserSubmission.get_local_filename(filename)
    self.update_attribute(field, UserSubmission.get_url_filename(filename))    
  end
  
  def get_base_filename
    "#{get_user_submission_dir}/#{UserSubmission.sanitize_filename(self.title)}"
  end
        
  def get_user_submission_dir
    user_submission_dir = "/user_generated_files/user_submissions/#{self.id}"
    local_dir = UserSubmission.get_local_filename(user_submission_dir)
    
    # File.exist? also works on directories
    # mode 0755 is read/write/execute for the user who creates the file, 
    # and read/execute for everyone else
    Dir.mkdir(local_dir, 0755) unless File.exist?(local_dir)     
    user_submission_dir
  end      
      
end