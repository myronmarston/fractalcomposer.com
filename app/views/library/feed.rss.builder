@generating_feed = true
xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Fractal Composer User Submissions"
    xml.description "Pieces Submitted by Fractal Composer Users"
    xml.link url_for(:action => :index, :only_path => false)
    xml.language "en-us"
    xml.managingEditor "myron@fractalcomposer.com"
    xml.webMaster "myron@fractalcomposer.com"
    xml.pubDate @user_submissions.size == 0 ? DateTime.now.to_s(:rfc822) : @user_submissions.first.updated_at.to_s(:rfc822)
    xml.lastBuildDate @user_submissions.size == 0 ? DateTime.now.to_s(:rfc822) : @user_submissions.first.updated_at.to_s(:rfc822)
    xml.docs URI.encode("http://cyber.law.harvard.edu/rss/rss.html")
    xml.ttl 20
    
    for @user_submission in @user_submissions
      xml.item do
        xml.title "#{@user_submission.title} by #{@user_submission.name}"
        xml.description do
          xml.cdata! render(:partial => 'library/piece.html.erb')
        end                  
        xml.pubDate @user_submission.created_at.to_s(:rfc822)
        xml.link url_for(:action => :view_piece, :id => @user_submission, :only_path => false)
        xml.guid url_for(:action => :view_piece, :id => @user_submission, :only_path => false)
      end
    end
  end
end