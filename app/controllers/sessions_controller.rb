require 'json'
require 'rest_client'

class SessionsController < ApplicationController
  before_filter :user_logged_out, :except  => :destroy
  before_filter :ensure_app_logout, :only => :new

  def create
    session[:form_username] = params[:username]
    rest_params = {:session => {}}
    rest_params[:session][:username] = params[:username]
    rest_params[:session][:password] = params[:password]
    rest_params[:session][:app_name] = APP_CONFIG.ASI_app_name
    rest_params[:session][:app_password] = APP_CONFIG.ASI_app_password

    begin
      response = RestClient.post APP_CONFIG.ASI + '/session', rest_params, { :cookies => session[:cookie] }
    rescue RestClient::Exception => e
      flash[:error] = "Incorrect username or password"
      redirect_to :action => :new and return
    end

    json = JSON.parse(response.body)
    session[:cookie] = response.cookies
    session[:person_id] = json["entry"]["user_id"]
    session[:form_username] = nil
    
    if session[:person_id]
      begin
        response = RestClient.get APP_CONFIG.ASI + '/people/' + session[:person_id] + '/@self', { :cookies => session[:cookie] }
        json = JSON.parse(response.body)
        print json.inspect
        if json["entry"]["name"] == nil
            session[:person_name] = json["entry"]["username"]
        else
            session[:person_name] = json["entry"]["name"]["unstructured"]
        end
      rescue RestClient::Exception => e
        flash[:warning] = "Could not fetch user profile"
        session[:person_name] = "Unknown"
      end
      redirect_to :controller => :home, :action => :index
    end
  end
  
  def destroy
    begin
      response = RestClient.delete APP_CONFIG.ASI + '/session', { :cookies => session[:cookie] }
    rescue RestClient::Exception => e
      print e.http_code
    end

    session[:cookie] = nil
    session[:person_id] = nil
    flash[:notice] = "Logout successful"
    redirect_to :controller => :home, :action => :index
  end
  
  def new
  end

end
