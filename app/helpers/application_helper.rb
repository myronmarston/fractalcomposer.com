# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def sanatize_input_id(input_name)
    # taken from ActionView::Helpers::FormHelper
    input_name.gsub(/[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
  end
end
