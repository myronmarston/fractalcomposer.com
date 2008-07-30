require 'jruby'
java.lang.Thread.currentThread.setContextClassLoader(JRuby.runtime.jruby_class_loader)

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
  
  GENERATED_IMAGE_WIDTH = 500 unless defined? GENERATED_IMAGE_WIDTH
  
  generate_validations
  validates_email_format_of :email
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
    
    process_save_file('.mp3', :mp3_file) {|f| piece_output_manager.saveMp3File(f)}
    process_save_file('.pdf', :piece_pdf_file) {|f| piece_output_manager.savePdfFile(f, self.title, self.name)}
    process_save_file('.png', :piece_image_file) {|f| piece_output_manager.savePngFile(f, self.title, self.name, GENERATED_IMAGE_WIDTH)}
    process_save_file('_germ.png', :germ_image_file) {|f| fractal_piece.createGermOutputManager.savePngFile(f, GENERATED_IMAGE_WIDTH)}
        
    self.update_attribute(:processing_completed, Time.now)    
  end
  
  private
  
  def process_save_file(extension, field)
    filename = get_base_filename + extension
    yield UserSubmission.get_local_filename(filename)
    self.update_attribute(field, UserSubmission.get_url_filename(filename))    
  end
  
  def get_base_filename
    "#{get_user_submission_dir}/#{UserSubmission.sanitize_filename(self.title)}"
  end
        
  def get_user_submission_dir
    user_submission_dir = "/user_submissions/#{self.id}"
    local_dir = UserSubmission.get_local_filename(user_submission_dir)
    
    # File.exist? also works on directories
    # mode 0755 is read/write/execute for the user who creates the file, 
    # and read/execute for everyone else
    Dir.mkdir(local_dir, 0755) unless File.exist?(local_dir)     
    user_submission_dir
  end      
  
  def get_lilypond_pdf
    "#{self.lilypond_results_file}.pdf"
  end
  
end