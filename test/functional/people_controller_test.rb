require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  
  def test_register
    get :register
    assert_response :success
    assert_template 'register'
  end

  def test_create
    get :create, { :username => 'Jani', :email => 'turunen.jani@gmail.com', :phone_number => '+1234567890', :consent => '1' } # user already in system
    assert_redirected_to :controller => :people, :action => :register
  end

end
