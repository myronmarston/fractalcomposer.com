class UserSubmissionsController < ApplicationController
  layout 'admin'
  active_scaffold :user_submissions do |config|
    config.actions.exclude :delete
    config.actions.exclude :create
    config.actions.exclude :update    
  end
end
