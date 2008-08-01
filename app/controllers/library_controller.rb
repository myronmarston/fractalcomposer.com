class LibraryController < ApplicationController
  before_filter :load_user_submission
  
  def index
    
  end
  
  def view_piece
    if @user_submission      
      if @user_submission.processing_completed.nil?        
        UserSubmissionProcessor.start_processor_if_necessary
        render :action => 'still_processing' 
      end      
    else
      #TODO: test the status code
      render :action => 'piece_not_found', :status => 404          
    end              
    
    # just render the view_piece template...
  end
  
  def rate    
    #TODO: prevent bots from rating this, using:
    # -> check user agent?
    # -> nofollow or some other attribute?
    @user_submission.rate params[:rating].safe_to_i, IpAddress.get(request.remote_ip)
    if request.xml_http_request?
      respond_to { |format| format.js } 
    else
      redirect_to :action => 'view_piece', :id => @user_submission
    end    
  end
  
  private
  
  def load_user_submission
    begin
      @user_submission = UserSubmission.find(params[:id]) if params.has_key?(:id)
    rescue ActiveRecord::RecordNotFound      
      @user_submission = nil
    end
  end
  
end
