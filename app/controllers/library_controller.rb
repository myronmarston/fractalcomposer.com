class LibraryController < ApplicationController
  
  def view_piece
    begin
      @user_submission = UserSubmission.find(params[:id])
      if @user_submission.processing_completed.nil?        
        UserSubmissionProcessor.start_processor_if_necessary
        render :action => 'still_processing' 
      end      
    rescue ActiveRecord::RecordNotFound
      # TODO: return the proper http error code
      render :action => 'piece_not_found'          
    end              
  end
  
end
