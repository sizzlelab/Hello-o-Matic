require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  def test_new_session
    get :new
    assert_response :success
    assert_template 'new'
  end
  
end
