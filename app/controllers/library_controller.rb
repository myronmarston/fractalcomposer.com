class LibraryController < ApplicationController
  EXAMPLE_IDS = [1, 2] unless defined? EXAMPLE_IDS
  LIST_CONDITIONS = "processing_completed IS NOT NULL AND id NOT IN (#{EXAMPLE_IDS.join(', ')})" unless defined? LIST_CONDITIONS
  PER_PAGE = 10 unless defined? PER_PAGE
  LIST_OPTIONS = [
    {
      :id => 'most_recent',
      :order => '',
      :columns => { 'Date' => :formatted_created_at },
      :page_param => :most_recent_page,
      :title_style => 'background-color: transparent; border: none'
    },
    {
      :id => 'highest_rated',
      :order => 'rating_avg DESC,',
      :columns => { 'Votes' => :rating_count, 'Rating' => :rating_avg },
      :additional_conditions => ' AND rating_count > 1',
      :page_param => :highest_rated_page
    },
    {
      :id => 'most_viewed',
      :order => 'unique_page_views DESC,',
      :columns => { '# of times viewed' => :unique_page_views },
      :page_param => :most_viewed_page
    },
    {
      :id => 'most_commented',
      :order => 'comment_count DESC,',
      :columns => { '# of comments' => :comment_count },
      :page_param => :most_commented_page
    },
    {
      :id => 'oldest_unrated',
      :additional_conditions => ' AND COALESCE(rating_count, 0) = 0',
      :order => 'created_at ASC,',
      :columns => { 'Date' => :formatted_created_at },
      :page_param => :oldest_unrated_page
    }
  ] unless defined? LIST_OPTIONS

  before_filter :load_user_submission
  before_filter :setup_negative_captcha, :only => [:view_piece, :add_comment, :examples]
  
  def index
    @page_title = 'Library'
    if request.xhr?
      # AJAX requests come from the pagination...
      matching_options = LIST_OPTIONS.select { |opt| opt[:id] == params[:list_type] }
      if matching_options.blank?
        head :not_found
        return
      end

      @options = matching_options.first.dup
      @options[:user_submissions] = get_user_submission_list(@options)
      render :partial => 'user_submission_table', :locals => @options
    else
      @list_options = LIST_OPTIONS.dup
      @list_options.each do |options|
        options[:user_submissions] = get_user_submission_list(options)
      end

      respond_to do |format|
        # google feed catcher keeps trying to get this with ?format=rss since I subscribed once will testing...
        format.html # use index view...
        format.rss { redirect_to 'http://feeds.feedburner.com/fractalcomposer' }
      end
    end
  end

  def search
    @page_title = 'Library Search'
    @query = params[:query]
    @page = params[:page] || 1

    if @page.to_i < 1
      redirect_to :overwrite_params => { :page => nil }
      return
    end

    @search_results = UserSubmission.paginate_search(@query, :page => @page, :per_page => PER_PAGE)

    if @search_results.blank? && @page.to_i > 1
      @page = @search_results.total_entries <= PER_PAGE ? nil : 1 + @search_results.total_entries / PER_PAGE
      redirect_to :overwrite_params => { :page => @page }
      return
    end
  end
  
  def generated_pieces
    @generated_pieces = GeneratedPiece.find(:all,
      :order => 'updated_at DESC',
      :limit => 20)
    
    @generating_feed = true

    respond_to do |format|     
      format.atom
    end    
  end
  
  def feed
    @user_submissions = UserSubmission.find(:all, 
      :conditions => LIST_CONDITIONS,
      :order => 'created_at DESC',
      :limit => 20)    

    # filter out unprocessed pieces...    
    @user_submissions = @user_submissions.select { |u| u.processed? }    

    @generating_feed = true

    respond_to do |format|     
      format.atom
    end    
  end
  
  def examples
    @page_title = 'Examples'
    @examples = UserSubmission.find(:all, :order => 'id', :conditions => { :id => EXAMPLE_IDS } )
    @examples.each {|e| UserSubmissionProcessor.start_processor_if_necessary unless e.processed?}
    @comment = flash[:comment]
    @valid = (@comment ? @comment.valid? : true) # true is the default so we don't get error messages
    @comment ||= Comment.new                               
  end
  
  def view_piece        
    if @user_submission      
        if EXAMPLE_IDS.include?(@user_submission.id)
          example_index = EXAMPLE_IDS.index(@user_submission.id) + 1
          tab = example_index == 1 ? nil : "example_#{example_index}"
          flash.keep
          redirect_to :action => :examples, :tab => tab
        else
          @page_title = "#{@user_submission.title} by #{@user_submission.name}"
          @user_submission.page_view(request.remote_ip)
          @comment = flash[:comment]
          @valid = (@comment ? @comment.valid? : true) # true is the default so we don't get error messages
          @comment ||= Comment.new                                             
        end        
    else      
      render :action => 'piece_not_found', :status => 404          
    end                  
  end
  
  def rate    
    #TODO: prevent bots from rating this, using:
    # -> check user agent?
    # -> nofollow or some other attribute?
    @user_submission.rate params[:rating].safe_to_i, IpAddress.get(request.remote_ip)
    if request.xml_http_request?
      respond_to { |format| format.js } 
    else
      redirect_to :action => 'view_piece', :slug => @user_submission.slug
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
      redirect_to :action => 'view_piece', :slug => @user_submission.slug
    end                
  end    
  
  private
  
  def load_user_submission
    return true unless params.has_key?(:slug) || params.has_key?(:id)

    slug = params[:slug] || params[:id]

    @user_submission = UserSubmission.find_by_slug(slug)

    if @user_submission.nil?
      # try to find it by id, since we didn't have slugs when we first launched the website...
      @user_submission = UserSubmission.find_by_id(slug)
      if @user_submission
        # redirect!
        redirect_to :slug => @user_submission.slug, :id => nil, :status => 301
        return false
      end
    end
  end
    
  def setup_negative_captcha
    @captcha = NegativeCaptcha.new(
      :secret => ::NEGATIVE_CAPTCHA_SECRET,
      :spinner => request.remote_ip, 
      :fields => [:name, :email, :website, :comment], #Whatever fields are in your form 
      :params => params)
  end

  def get_user_submission_list_page(options, page_num)
    UserSubmission.paginate(
        :all,
        :conditions => "#{LIST_CONDITIONS}#{options[:additional_conditions] || ''}",
        :order => "#{options[:order]}created_at DESC",
        :per_page => PER_PAGE,
        :page => page_num)
  end

  def get_user_submission_list(options)
    page = params[options[:page_param]] || 1
    page = 1 if page.to_i < 1

    user_submissions = get_user_submission_list_page(options, page)

    if user_submissions.blank? && page.to_i > 1
      user_submissions = get_user_submission_list_page(options, 1 + user_submissions.total_entries / PER_PAGE)
    end

    return user_submissions
  end

end
