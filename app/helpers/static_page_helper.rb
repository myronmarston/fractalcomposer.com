module StaticPageHelper
  def acknowledgement(title, url)
    content_tag(:li, link_to(title, url))
  end
end
