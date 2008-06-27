require File.dirname(__FILE__) + '/../test_helper'

class UserSubmissionTest < ActiveSupport::TestCase
  
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
      piece.save!
      submission.generated_piece = piece
      assert submission.valid?, "Unexpected error(s): #{submission.errors.inspect}"
    end    
  end
  
  def test_validates_email_address        
    # now provide values for all these fields...     
    fillin_generated_piece_values do |piece|
      piece.save!
      
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
     # now provide values for all these fields...     
    fillin_generated_piece_values do |piece|
      piece.save!
      
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
    
end
