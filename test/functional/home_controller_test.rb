require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  def test_show_index
    get :index
    assert_response :success
    assert_template 'index'
  end

  def test_show_thanks
    get :thanks
    assert_response :success
    assert_template 'thanks'
  end

  def test_send_hello_without_being_logged_in
    get :sendhello, {:phone_number => '+358501234567'}
    assert_redirected_to :controller => :session, :action => :new
  end

end
