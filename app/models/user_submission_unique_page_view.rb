class UserSubmissionUniquePageView < ActiveRecord::Base
  ELAPSED_TIME_FOR_UNIQUE_PV = 6.hours unless defined? ELAPSED_TIME_FOR_UNIQUE_PV
  
  def self.page_view(user_submission, ip_address)
    # A unique page view is defined as a page view on a unique ip address for
    # a user submission, or, if that ip has viewed the page before, it will be
    # a new unique ip address if more than 6 hours has passed since the last page
    # view.  This is meant to prevent people from artifically inflating their
    # piece's page views just be obsessively refreshing.
    
    existing_pv = self.find(:first, 
      :conditions => ['user_submission_id = ? AND ip_address = ? AND updated_at > ?',
                       user_submission.id,        ip_address,        Time.now.ago(ELAPSED_TIME_FOR_UNIQUE_PV)])

    if existing_pv
      existing_pv.update_attributes!(:updated_at => Time.now)  
    else
      self.create!(:user_submission_id => user_submission.id, :ip_address => ip_address)      
    end              
  end
  
  def after_create
    UserSubmission.increment_counter(:unique_page_views, self.user_submission_id)
  end
  
end
