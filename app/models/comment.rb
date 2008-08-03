class Comment < ActiveRecord::Base
  MISSING_FIELD_ERROR_MSG = 'is required' unless defined? MISSING_FIELD_ERROR_MSG
  DUPLICATE_COMMENT_ERROR_MSG = 'Your comment has already been posted.' unless defined? DUPLICATE_COMMENT_ERROR_MSG
  
  belongs_to :commentable, :polymorphic => true
  validates_presence_of :comment, :ip_address, :name, :email, :message => MISSING_FIELD_ERROR_MSG
  validates_email_format_of :email, :if => :do_email_validation?  
  validates_http_url :website
  attr_accessor :is_website_tester
  attr_accessor :is_preview
  
  def before_validation
    return if self.is_website_tester
    return if self.website.nil? || self.website == '' 
    
    #add the "http://" if it is an invalid website and that would make it valid...
    test_comment = Comment.new
    test_comment.is_website_tester = true
    test_comment.website = self.website
    if !test_comment.valid? && test_comment.errors.invalid?(:website)
      test_comment.website = "http://#{test_comment.website}"
      
      test_comment.valid?
      if !test_comment.errors.invalid?(:website)
        self.website = test_comment.website
      end
    end
  end 
  
  def after_create
    if self.commentable_type == UserSubmission.to_s
      UserSubmission.increment_counter(:comment_count, self.commentable_id)
    end    
  end
  
  def after_destroy
    if self.commentable_type == UserSubmission.to_s
      UserSubmission.decrement_counter(:comment_count, self.commentable_id)
    end    
  end

  def validate
    # prevent duplicates...
    existing_comment = Comment.find(:first, 
      :conditions => ['commentable_type = ? and commentable_id = ? and name = ? and email = ? and website = ? and comment = ?',
                       commentable_type,        commentable_id,        name,        email,        website,        comment])
                   
    errors.add_to_base(DUPLICATE_COMMENT_ERROR_MSG) if existing_comment                        
  end
  
  def created_at_description
    # if this comment is a preview, there won't be a value for created_at,
    # so we use Time.now for preview instead
    time_to_use = self.created_at || Time.now
    time_to_use.strftime("on %A, %B %d, %Y at %I:%M %p")
  end
  
  def song_name
    #return "" if self.commentable.nil? || self.commentable.class != 'Song'
    return self.commentable.title if self.commentable.respond_to? :title
  end
  
  
  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  def self.find_comments_by_user(user)
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC"
    )
  end
  
  # Helper class method to look up all comments for 
  # commentable class name and commentable id.
  def self.find_comments_for_commentable(commentable_str, commentable_id)
    find(:all,
      :conditions => ["commentable_type = ? and commentable_id = ?", commentable_str, commentable_id],
      :order => "created_at DESC"
    )
  end

  # Helper class method to look up a commentable object
  # given the commentable class name and id 
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end
  
  def is_preview?
    self.is_preview
  end 
  
  def html_div_id
    self.is_preview? ? "comment_preview" : "comment_#{self.id}"
  end
  
  def hpricoted_comment
    self.comment
    #figure this out later...
#    require 'hpricot'
#    h = Hpricot(self.comment)
#    h.to_html
  end
  
  protected
  
  def do_email_validation?
    self.email && self.email != ''
  end
  
end