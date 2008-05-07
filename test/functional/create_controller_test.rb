require File.dirname(__FILE__) + '/../test_helper'

class CreateControllerTest < ActionController::TestCase
  
  def test_routings
    assert_routing("/create", :controller => "create", :action => "index")        
  end
        
end