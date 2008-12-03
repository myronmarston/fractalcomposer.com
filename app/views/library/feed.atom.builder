fc_atom_feed(:schema_date => Date.civil(2008, 12, 3), :root_url => root_url ) do |feed|
   feed.title("Fractal Composer User Submission Library")
   feed.updated(@user_submissions.size == 0 ? DateTime.now : @user_submissions.first.created_at)   
   
   feed.author do |author|
      author.name 'Myron Marston'
      author.email 'myron@fractalcomposer.com'
      author.uri 'http://fractalcomposer.com/'
   end
   
   feed.rights '&copy;2008 Myron Marston', :type => 'html'
  
   for @user_submission in @user_submissions
     feed.entry(@user_submission, :url => url_for(:action => :view_piece, :slug => @user_submission.slug, :only_path => false) ) do |entry|
       entry.link :rel => 'license', :type => 'application/rdf+xml', :href => "#{LICENSE_URL}rdf"
       # the piece goes first, since some feed readers can only handle one enclosure...
       entry_mp3_enclosure(entry, @user_submission.piece_mp3_file)       
       entry_mp3_enclosure(entry, @user_submission.germ_mp3_file)       
       entry.title(@user_submission.title)             
                         
       entry.author do |author|
         author.name(@user_submission.name)
         author.uri(@user_submission.website) unless @user_submission.website.blank?
       end
      
       entry.content(:type => 'html') do |content|
         content.cdata! render(:partial => 'library/piece.html.erb')
       end
     end
   end
 end
