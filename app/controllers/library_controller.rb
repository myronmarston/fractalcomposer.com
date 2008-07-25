class LibraryController < ApplicationController
  
  def view_piece
    begin
      @user_submission = UserSubmission.find(params[:id])
      @user_submission.start_processing_if_needed
      render :action => 'still_processing' if @user_submission.processing_completed.nil?        
    rescue ActiveRecord::RecordNotFound
      # TODO: return the proper http error code
      render :action => 'piece_not_found'          
    end              
  end
  
end
