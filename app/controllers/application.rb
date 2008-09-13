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
    
  # taken from http://groups.google.com/group/jruby-users/browse_thread/thread/e703e3acd2f9bed7/baee5d58f5fb6d58?lnk=gst&q=render_optional_error_file#
  def render_optional_error_file(status_code)
    status = interpret_status(status_code)
    path = "#{PUBLIC_ROOT}/#{status[0,3]}.html"
    if File.exists?(path)
     render :file => path, :status => status
    else
     head status
    end
  end
  
  # overrides of exception notifiable methods to use new PUBLIC_ROOT constant
  def render_404
      respond_to do |type|
        type.html { render :file => File.join(PUBLIC_ROOT, '404.html'), :status => "404 Not Found" }
        type.all  { render :nothing => true, :status => "404 Not Found" }
      end
    end

    def render_500
      respond_to do |type|
        type.html { render :file => File.join(PUBLIC_ROOT, '500.html'), :status => "500 Error" }
        type.all  { render :nothing => true, :status => "500 Error" }
      end
    end

end
