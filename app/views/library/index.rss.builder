xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Fractal Composer User Submissions"
    xml.description "Pieces Submitted by Fractal Composer Users"
    xml.link url_for(:action => :index, :format => :rss, :only_path => false)
    xml.language "en-us"
    xml.managingEditor "myron@fractalcomposer.com"
    xml.webMaster "myron@fractalcomposer.com"
    xml.pubDate DateTime.now.to_s(:rfc822)
    
    for @user_submission in @user_submissions
      xml.item do
        xml.title "#{@user_submission.title} by #{@user_submission.name}"
        xml.description @user_submission.description
        xml.pubDate @user_submission.created_at.to_s(:rfc822)
        xml.link url_for(:action => :view_piece, :id => @user_submission, :only_path => false)
        xml.guid url_for(:action => :view_piece, :id => @user_submission, :only_path => false)
      end
    end
  end
end