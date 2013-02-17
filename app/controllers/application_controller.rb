class ApplicationController < ActionController::Base
  protect_from_forgery

  respond_to :html, :xml, :json, :xbmc

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
  protected

  def record_not_found
    redirect_to :root, :flash => { :error => t('errors.messages.not_found') }
  end
end
