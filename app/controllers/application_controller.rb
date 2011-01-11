# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'json'
require 'rest_client'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  def ensure_app_login
    s = _get_session
    if s["entry"]["app_id"] == nil
      # if we don't have an ASI session, log in as the application
      rest_params = {:session => {}}
      rest_params[:session][:app_name] = APP_CONFIG.ASI_app_name
      rest_params[:session][:app_password] = APP_CONFIG.ASI_app_password
      begin
        response = RestClient.post APP_CONFIG.ASI + '/session', rest_params,  { :cookies => session[:cookie] }
      rescue RestClient::Exception => e
        flash[:error] = "Could not reach ASI. Try again later."
        redirect_to :controller => :home, :action => :index
      end
      session[:cookie] = response.cookies
    end
  end

  def ensure_app_logout
    s = _get_session
    if s["entry"]["app_id"] != nil
      # if we do have an ASI session, delete it
      begin
        response = RestClient.delete APP_CONFIG.ASI + '/session',  { :cookies => session[:cookie] }
      rescue RestClient::Exception => e
        flash[:error] = "Could not reach ASI. Try again later."
        redirect_to :controller => :home, :action => :index
      end
      session[:cookie] = response.cookies
    end
  end
    
  def user_logged_out
    if _is_user_logged_in
      # redirect to the home page
      redirect_to :controller => :home, :action => :index and return false
    end
  end

  def user_logged_in
    if not _is_user_logged_in
      # redirect to the login page
      redirect_to :controller => :session, :action => :new and return false
    end
  end
  
  def _get_session
    begin
      response = RestClient.get APP_CONFIG.ASI + '/session', { :cookies => session[:cookie] }
      return JSON.parse(response.body)
    rescue RestClient::Exception => e
      return { 'entry' => { 'app_id' => nil, 'user_id' => nil } } # hardcoded to copy ASI notation
    end
  end

  def _is_user_logged_in
    s = _get_session
    if s["entry"]["user_id"] != nil
      session[:person_id] = s["entry"]["user_id"]
      return true
    else
      session[:person_id] = nil
      return false
    end
  end

end
