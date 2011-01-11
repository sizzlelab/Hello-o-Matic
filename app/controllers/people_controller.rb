class PeopleController < ApplicationController
  before_filter :ensure_app_login
  before_filter :user_logged_out, :only  => [:create, :register]

  def register
  end
  
  def create
    session[:form_username] = params[:username]
    session[:form_email] = params[:email]
    session[:form_phone_number] = params[:phone_number]
    session[:form_consent] = params[:consent]

    if params[:username].eql?('')
      flash[:error] = "Please enter a username"
      redirect_to :action => :register and return
    end
    
    if not params[:password].eql?(params[:password2]) or params[:password].eql?('')
      flash[:error] = "Password invalid or do not match"
      redirect_to :action => :register and return
    end

    if params[:email].eql?('')
      flash[:error] = "Please enter a email"
      redirect_to :action => :register and return
    end

    if params[:phone_number].eql?('')
      flash[:error] = "Please enter a phone number"
      redirect_to :action => :register and return
    end

    if params[:consent].eql?(1)
      flash[:error] = "Please consent"
      redirect_to :action => :register and return
    else
        params[:consent] = "TEST CONSENT"
    end

    rest_params = {:person => {}}
    rest_params[:person][:username] = params[:username]
    rest_params[:person][:password] = params[:password]
    rest_params[:person][:email] = params[:email]
    rest_params[:person][:phone_number] = params[:phone_number]
    rest_params[:person][:consent] = params[:consent]

    begin
      response = RestClient.post APP_CONFIG.ASI + '/people', rest_params, { :cookies => session[:cookie] }
    rescue RestClient::Exception => e
      flash[:error] = "Could not create new user, please try again later!"
      redirect_to :action => :register and return
    end

    json = JSON.parse(response.body)
    session[:cookie] = response.cookies
    session[:person_id] = json["entry"]["id"]

    session[:person_name] = session[:form_username]

    session[:form_username] = nil
    session[:form_email] = nil
    session[:form_phone_number] = nil
    session[:form_consent] = nil
    
    if session[:person_id]
      redirect_to :controller => :home, :action => :index and return
    end
  end

end
