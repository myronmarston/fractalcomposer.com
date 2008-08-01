class LibraryController < ApplicationController
  before_filter :load_user_submission
  
  def index
    
  end
  
  def view_piece
    begin
      if @user_submission.processing_completed.nil?        
        UserSubmissionProcessor.start_processor_if_necessary
        render :action => 'still_processing' 
      end      
    rescue ActiveRecord::RecordNotFound
      # TODO: return the proper http error code
      render :action => 'piece_not_found'          
    end              
  end
  
  def rate
    @user_submission.rate params[:rating].safe_to_i, IpAddress.get(request.remote_ip)
    if request.xml_http_request?
      respond_to { |format| format.js } 
    else
      redirect_to :action => 'view_piece', :id => @user_submission
    end    
  end
  
  private
  
  def load_user_submission
    @user_submission = UserSubmission.find(params[:id]) if params.has_key?(:id)
  end
  
end
