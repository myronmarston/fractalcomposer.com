module LibraryHelper
  
  def user_submission_title_by_name    
    "&#8220;#{@user_submission.title}&#8221; by #{link_to_if(@user_submission.website && @user_submission.website != '', @user_submission.name, @user_submission.website)}"
  end
  
  def rating_stars
    html = ""
    1.upto(5) {|i| html << rating_star(i)}
    html
  end
  
  def rating_star(num)
    num_spelled_out = case num
      when 1 then 'one'
      when 2 then 'two'
      when 3 then 'three'
      when 4 then 'four'
      when 5 then 'five'
      else raise 'Unknown number: ' + num
    end
    
    star_or_stars = (num == 1 ? 'star' : 'stars')
    id = "rate_link_#{num}"
    url_hash = { :action => :rate, :id => @user_submission, :rating => num }
    link = link_to(num.to_s, url_hash,
        {:id => id,
         :class => "#{num_spelled_out}-#{star_or_stars}", 
         :title => "#{num} #{star_or_stars} out of 5",
         :onclick => 'return false;'
        })
    
    js = "Event.observe('#{id}', 'click', function() {#{remote_function(:url => url_hash, :before => "$('star_rating_spinner').show()", :complete => "$('star_rating_spinner').hide()")};})"
    
    <<-EOS
    <li>
        #{link}
        #{javascript_tag(js)}
    </li>
    EOS
  end
  
  def current_rating_description
    "Currently Rated #{number_with_precision(@user_submission.rating_average, 1)} out of 5 Stars (#{pluralize(@user_submission.rating_count, 'Vote')})"
  end
  
end
