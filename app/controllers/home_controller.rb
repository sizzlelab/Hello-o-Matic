class HomeController < ApplicationController
  before_filter :user_logged_in, :only => :sendhello
  
  def index
  end
  
  def sendhello
    session[:form_phone_number] = params[:phone_number]

    rest_params = {}
    rest_params[:number] = params[:phone_number]
    rest_params[:text] = "HELLO"
    
    begin
      response = RestClient.post APP_CONFIG.ASI + '/sms', rest_params, { :cookies => session[:cookie] }
    rescue RestClient::Exception => e
      flash[:error] = "Could not send Hello. Please try again later."
      redirect_to :action => :index and return
    end
    session[:form_phone_number] = nil
    redirect_to :controller => :home, :action => :thanks
  end
  
  def thanks
  end
  
end
