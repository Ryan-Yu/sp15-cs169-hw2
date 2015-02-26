class ApplicationController < ActionController::Base
  protect_from_forgery

  alias :std_redirect_to :redirect_to
  def redirect_to(*args)
  	flash.keep
  	std_redirect_to *args
  end
  
end
