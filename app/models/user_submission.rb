class UserSubmission < ActiveRecord::Base
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
end
