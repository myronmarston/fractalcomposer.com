class UserSubmissionsController < ApplicationController
  layout 'admin'
  active_scaffold :user_submissions do |config|
    config.actions.exclude :delete
    config.actions.exclude :create
    config.actions.exclude :update    
  end

  #todo: is there a new, valid xhtml version of active scaffold?
  
#  active_scaffold :user_submissions do |config|
#    config.actions.exclude :delete
#    config.actions.exclude :create
#    config.actions.exclude :update    
#    config.columns = [:title, :name, :rating_avg, :comment_count, :unique_page_views, :created_at]    
#  end
  
end
