# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  before_filter :set_locale
  after_filter :set_charset
  
  private
  
    def set_charset 
      headers["Content-Type"] = "text/html; charset=utf-8" if headers["Content-Type"].blank? 
    end  
  

    def set_locale 
      accept_lang = request.env['HTTP_ACCEPT_LANGUAGE'] 
      accept_lang = accept_lang.blank? ? nil : accept_lang[/[^,;]+/]
      
      locale = params[:locale] || session[:locale] || accept_lang || DEFAULT_LOCALE 
      begin 
        Locale.set locale 
        session[:locale] = locale 
      rescue 
        Locale.set DEFAULT_LOCALE 
      end 
    end 

    def initialize_cart
      if session[:cart_id]
        @cart = Cart.find(session[:cart_id])
      else
        @cart = Cart.create
        session[:cart_id] = @cart.id
      end
    end
end