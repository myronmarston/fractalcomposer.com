module LibraryHelper
  
  def user_submission_title_by_name    
    "&#8220;#{@user_submission.title}&#8221; by #{link_to_if(@user_submission.website && @user_submission.website != '', @user_submission.name, @user_submission.website)}"
  end
  
end
