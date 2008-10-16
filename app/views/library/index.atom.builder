atom_feed(:schema_date => Date.civil(2008, 10, 15)) do |feed|
   feed.title("Fractal Composer User Submission Library")
   feed.updated(@user_submissions.size == 0 ? DateTime.now : @user_submissions.first.created_at)

   for @user_submission in @user_submissions
     feed.entry(@user_submission, :url => url_for(:action => :view_piece, :id => @user_submission.id, :only_path => false) ) do |entry|
       entry.title(@user_submission.title)
       entry.content(link_to("#{@user_submission.title} by #{@user_submission.name}", :action => :view_piece, :id => @user_submission.id, :only_path => false), :type => 'html')

       entry.author do |author|
         author.name(@user_submission.name)
       end
     end
   end
 end
