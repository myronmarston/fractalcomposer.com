require File.dirname(__FILE__) + '/../test_helper'
require 'path_helper'

class UserSubmissionTest < ActiveSupport::TestCase
  extend PathHelper
  
   def test_empty_strings
     fillin_generated_piece_values do |piece|
      submission = UserSubmission.new
      submission.email = 'test@mailinator.com'     
      submission.generated_piece = piece
      submission.title = '   '      
      submission.name = '    '      
      assert !submission.valid?, 'Strings with spaces were improperly allowed.'
      [:name, :title].each do |field|
        assert submission.errors.invalid?(field), "Field #{field} should be invalid and is not."
      end       
      
      submission.title = 'Test title'
      submission.title = 'Test name'
    end             
   end
  
   def test_required_fields
    submission = UserSubmission.new
    assert !submission.valid?
    
    [:name, :email, :title, :generated_piece_id].each do |field|
      assert submission.errors.invalid?(field), "Field #{field} was not required as expected"
    end       
    
    # now provide values for all these fields... 
    submission.name = 'Myron'
    submission.email = 'test@mailinator.com'
    submission.title = 'Fractoid #6'
    
    fillin_generated_piece_values do |piece|      
      submission.generated_piece = piece
      assert submission.valid?, "Unexpected error(s): #{submission.errors.inspect}"
    end    
  end
  
  def test_validates_email_address        
    # now provide values for all these fields...     
    fillin_generated_piece_values do |piece|
      submission = UserSubmission.new
      submission.generated_piece = piece
      submission.name = 'Myron'      
      submission.title = 'Fractoid #6'
      
      submission.email = 'alsdfjkdas'
      assert !submission.save, 'The email was not invalid as expected.'
      assert submission.errors.invalid?(:email), 'The email was not invalid as expected.'
      
      submission.email = 'test@mailinator.com'
      assert submission.save, "Unexpected error(s): #{submission.errors.inspect}"           
    end      
  end
  
  def test_validates_website
    fillin_generated_piece_values do |piece|            
      submission = UserSubmission.new
      submission.generated_piece = piece
      submission.name = 'Myron'      
      submission.title = 'Fractoid #6'
      submission.email = 'test@mailinator.com'
      
      submission.website = 'ladsjkfalsd'
      assert !submission.valid?, 'The submission website was not properly invalidated.'
      assert submission.errors.invalid?(:website), 'The website was not invalid as expected.'
      
      submission.website = 'http://www.boguswebsitethatdoesnotexist.com'
      assert !submission.valid?, 'The submission website was not properly invalidated.'
      assert submission.errors.invalid?(:website), 'The website was not invalid as expected.'
      
      submission.website = 'http://www.google.com'
      assert submission.valid?, "Unexpected error(s): #{submission.errors.inspect}"
      
      # try it without the http://
      submission.website = 'www.google.com'
      assert submission.valid?, "Unexpected error(s): #{submission.errors.inspect}"      
    end        
  end
  
  def test_processing
    fillin_generated_piece_values do |piece|
      submission = UserSubmission.new
      submission.generated_piece = piece
      submission.name = 'Myron'      
      submission.title = 'Fractoid #6'
      submission.email = 'test@mailinator.com'            
      
      assert submission.save, 'The submission could not be saved as expected.'
      id = submission.id
      
      time1 = Time.now      
      while (time1 > 3.minutes.ago) # wait a max of 3 minutes
        test_submission = UserSubmission.find(id)
        break if test_submission.processing_completed
      end
      
      saved_submission = UserSubmission.find(id)
      assert !saved_submission.processing_began.nil?, 'The processing_began field should have a value.'
      assert !saved_submission.processing_completed.nil?, 'The processing_completed field should have a value.'
      assert !saved_submission.mp3_file.nil?, 'The mp3_file field should have a value.'
      assert File.exist?(UserSubmissionTest.get_local_filename(saved_submission.mp3_file)), 'The mp3 file does not exist as expected.'
    end
  end
  
  def test_get_pdf_filename
    us = UserSubmission.new
    us.lilypond_results_file = 'Piece_Title'
    assert 'Piece_Title.pdf', us.get_lilypond_pdf
  end
    
end
