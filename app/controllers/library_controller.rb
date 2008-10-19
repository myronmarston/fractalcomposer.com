class LibraryController < ApplicationController
  before_filter :load_user_submission
  before_filter :setup_negative_captcha, :only => [:view_piece, :add_comment]
  
  def index
    @user_submissions = UserSubmission.find(:all, :conditions => 'processing_completed IS NOT NULL', :order => 'updated_at DESC')
  end
  
  def view_piece
    if @user_submission      
      unless @user_submission.processed?
        UserSubmissionProcessor.start_processor_if_necessary
        render :action => 'still_processing' 
      else
        @user_submission.page_view(request.remote_ip)
        @comment = flash[:comment]
        @valid = (@comment ? @comment.valid? : true) # true is the default so we don't get error messages
        @comment ||= Comment.new                       
      end      
    else      
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
  
  def add_comment
    # Get odd or even for what this comment will be if it gets added.
    @odd_or_even_comment = (@user_submission.comments.size.even? ? 'odd' : 'even')
        
    # get the decrypted values, and a few of my own
    vals = @captcha.values.merge(
      :ip_address => request.remote_ip,
      :commentable_type => UserSubmission.to_s,
      :commentable_id => @user_submission.id
    )     
    
    @comment = Comment.new(vals)              
        
    # there are different ways to tell if the user clicked 'Preview' or 'Post Comment'
    # depending on if this is an AJAX request or not
    button_param = ( request.xml_http_request? ? :clicked_button : :commit )    
    @comment.is_preview = (params[button_param] == 'Preview')    
    
    @valid = ( @captcha.valid? && !@comment.is_preview? ? @comment.save : @comment.valid? && @captcha.valid? )
    @is_valid_non_preview = @valid && !@comment.is_preview?
    
    # add the captcha error as necessary...
    @comment.errors.add_to_base(@captcha.error) unless @captcha.valid?
        
    # add it to the comments if it's a valid non-preview comment    
    @user_submission.comments << @comment if @is_valid_non_preview
            
    if request.xml_http_request?
      respond_to { |format| format.js } 
    else
      # if the comment is invalid, pass on the comment to the redirect so that
      # we can use it to preserve what the user typed
      flash[:comment] = @comment unless @is_valid_non_preview
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
    
  def setup_negative_captcha
    @captcha = NegativeCaptcha.new(
      :secret => ::NEGATIVE_CAPTCHA_SECRET,
      :spinner => request.remote_ip, 
      :fields => [:name, :email, :website, :comment], #Whatever fields are in your form 
      :params => params)
  end

end
