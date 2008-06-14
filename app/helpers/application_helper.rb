# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def sanatize_input_id(input_name)
    # taken from ActionView::Helpers::FormHelper
    input_name.gsub(/[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
  end
  
  def clear_computed_public_path_for_image(source)
    # Paths that are formed by calling methods like image_tag are cached.
    # This causes issues for my dynamically generated images, as new versions
    # are not returned to the browser.  To fix this, we can remove the computed
    # path from the cache.
    
    # this code is adapted from the compute_public_path method found in asset_tag_helper.rb
    dir = "images"
    ext = nil
    include_host = true
    has_request = @controller.respond_to?(:request)
    cache_key =
      if has_request
        [ @controller.request.protocol,
          ActionController::Base.asset_host.to_s,
          @controller.request.relative_url_root,
          dir, source, ext, include_host ].join
      else
        [ ActionController::Base.asset_host.to_s,
          dir, source, ext, include_host ].join
      end
      
    ActionView::Base.computed_public_paths.delete cache_key
  end

end
