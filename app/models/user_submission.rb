require 'rubygems'
require 'rufus/scheduler'

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
    start_processing_if_needed
  end
  
  def start_processing_if_needed
    return if self.processing_completed
        
    if self.processing_began.nil? || self.processing_began < Time.now.minutes_ago(60)
      # if the processing began more than an hour ago, it must have failed for
      # some reason, such as the server being killed mid-process, so start it again
      
      # todo: does the thread terminate when it is done or do I need to kill it?
      scheduler = Rufus::Scheduler.start_new
      scheduler.schedule_in('1s') do # begin immediately...
          UserSubmission.generate_mp3_and_pdf_files(self.id)
      end
    end    
  end  
  
  def self.generate_mp3_and_pdf_files(user_submission_id)            
    user_submission = UserSubmission.find(user_submission_id)
    user_submission.update_attribute(:processing_began, Time.now)    
    generated_piece = user_submission.generated_piece    
        
    fractal_piece = com.myronmarston.music.settings.FractalPiece.loadFromXml(generated_piece.fractal_piece)
    output_manager = fractal_piece.createPieceResultOutputManager    
    
    user_submission_dir = user_submission.get_user_submission_dir
    mp3_filename = "#{user_submission_dir}/#{UserSubmission.sanitize_filename(user_submission.title)}.mp3"
    
    output_manager.saveMp3File(UserSubmission.get_local_filename(mp3_filename))
    user_submission.update_attribute(:mp3_file, UserSubmission.get_url_filename(mp3_filename))
    
    #TODO: generate pdf file    
    
    user_submission.update_attribute(:processing_completed, Time.now)    
  end
  
  def get_user_submission_dir()
    user_submission_dir = "/user_submissions/#{self.id}"
    local_dir = UserSubmission.get_local_filename(user_submission_dir)
    
    # File.exist? also works on directories
    # mode 0755 is read/write/execute for the user who creates the file, 
    # and read/execute for everyone else
    Dir.mkdir(local_dir, 0755) unless File.exist?(local_dir)     
    user_submission_dir
  end      
  
end