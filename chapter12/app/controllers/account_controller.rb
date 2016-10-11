class AccountController < ApplicationController
  observer :user_observer 
  # Be sure to include AuthenticationSystem in Application Controller instead
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if current_user
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/account', :action => 'index')
      flash[:notice] = "Logged in successfully"
    end
    flash.now[:notice] = "Incorrect login!" 
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    self.current_user = @user
    redirect_back_or_default(:controller => '/account', :action => 'index')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/account', :action => 'index')
  end
  
  
  def forgot_password 
    return unless request.post? 
    if @user = User.find_by_email(params[:email]) 
      @user.forgot_password 
      @user.save 
      flash[:notice] = "An email with instructions for resetting your password 
                        has been sent to your email address." 
      redirect_back_or_default(:controller => "/account") 
    else
      flash.now[:notice] = "Could not find a user with the given email address."
    end
  end
  
  def reset_password 
    @page_title = "Reset Password" 
    @user = User.find_by_pw_reset_code(params[:id]) rescue nil 
    unless @user 
      render(:text => "Not found", :status => 404) 
      return 
    end 
    return unless request.post? 
    if @user.update_attributes(params[:user]) 
      @user.reset_password 
      flash[:notice] = "Password successfully reset." 
      redirect_back_or_default(:controller => "/account") 
    end
  end
end
