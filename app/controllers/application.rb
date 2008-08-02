# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  local_addresses.clear
  before_filter :protect_xhr_actions  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # TODO: try using this
  #protect_from_forgery :secret => '6d5f829862d5cd3b9c825f3793d6b7d4'
    
  protected
  
  # protects all actions which end with '_xhr' against a direct call (no xhr)
  # taken from http://www.webdevbros.net/2007/12/05/protect-your-xhr-actions-ror/
  def protect_xhr_actions    
    redirect_to '/compose' and false if self.action_name.ends_with?('_xhr') and !request.xhr?
  end

end
