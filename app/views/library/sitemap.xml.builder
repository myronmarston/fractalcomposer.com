xml.instruct! :xml, :version=> '1.0', :encoding => 'UTF-8'
xml.urlset(:xmlns=>'http://www.sitemaps.org/schemas/sitemap/0.9') do
  @page_data.each do |page_hash|
    xml.url do
      xml.loc url_for(page_hash[:url_options].merge({:only_path => false}))
      xml.changefreq page_hash[:changefreq]
      xml.priority page_hash[:priority]
      xml.lastmod page_hash[:last_view_file_timestamp].utc.to_s(:w3c_datetime)
    end
  end

  @pieces.each do |piece|

    xml.url do
      xml.loc url_for(:controller => 'library', :action => 'view_piece', :slug => piece.slug, :only_path => false)
      xml.changefreq 'daily'
      xml.priority 0.5
      xml.lastmod [@view_piece_file_last_changed, piece.updated_at].max.utc.to_s(:w3c_datetime)
    end
  end
end
