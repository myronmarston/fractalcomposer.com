require File.dirname(__FILE__) + '/../test_helper'

class UserSubmissionsTest < ActiveSupport::TestCase
  
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
  
  
end
