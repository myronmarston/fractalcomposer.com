module LibraryHelper
  include ActionView::Helpers::FCAtomFeedHelper
  
  def user_submission_title_by_name    
    "&#8220;#{h @user_submission.title}&#8221; by #{link_to_if(@user_submission.website && @user_submission.website != '', h(@user_submission.name), h(@user_submission.website))}"
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
    id = "rate_link_#{num}_#{@user_submission.id}"
    url_hash = { :controller => :library, :action => :rate, :slug => @user_submission.slug, :rating => num }
    link = link_to(num.to_s, url_hash,
        {:id => id,
         :class => "#{num_spelled_out}-#{star_or_stars}", 
         :title => "#{num} #{star_or_stars} out of 5",
         :onclick => 'return false;'
        })
    
    js = "Event.observe('#{id}', 'click', function() {#{remote_function(:url => url_hash, :before => "$('star_rating_spinner_#{@user_submission.id}').show()", :complete => "$('star_rating_spinner_#{@user_submission.id}').hide()")};})"
    
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
  
  def comment_form_button_js(id)
    javascript_tag("Event.observe('#{id}', 'click', function() { $('clicked_button_#{@user_submission.id}').value = $('#{id}').value; });")
  end
  
  def entry_mp3_enclosure(entry, mp3_file)
    entry.link(
        :rel => 'enclosure', 
        :type => 'audio/mpeg', 
        :length => File.size(get_local_filename(mp3_file)), 
        :href => get_full_url_filename(mp3_file, request)
    )       
  end
  
  def entry_midi_enclosure(entry, midi_file)
    entry.link(
        :rel => 'enclosure', 
        :type => 'audio/mid', 
        :length => File.size(get_local_filename(midi_file)), 
        :href => get_full_url_filename(midi_file, request)
    )       
  end
  
  def generated_piece_germ_by_ip
    "#{@generated_piece.germ} by #{@generated_piece.user_ip_address}"  
  end

  def search_excerpts(user_submission)
    query_regex = /#{Regexp.escape(@query)}/i
    excerpts = []

    add_excerpt(excerpts, user_submission.description, @query, query_regex, false)
    
    user_submission.comments.each do |comment|
      add_excerpt(excerpts, "#{comment.name} said: #{comment.comment}", @query, query_regex)
    end

    return excerpts
  end

  private

  def add_excerpt(excerpts, text, query, query_regex, only_if_query_match = true)
    if text =~ query_regex
      excerpts << highlight(excerpt(text, query), query)
    elsif !only_if_query_match && !text.blank?
      excerpts << truncate(text, 100)
    end
  end
  
end
