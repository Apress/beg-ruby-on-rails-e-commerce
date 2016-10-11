class UserNotifier < ActionMailer::Base 
  @@session = ActionController::Integration::Session.new 
  def forgot_password(user) 
    setup_email(user) 
    @subject += "Password reset" 
    @body[:url] = @@session.url_for(:controller => "account", 
                          :action => "reset_password", 
                          :id => user.pw_reset_code, :only_path => false) 
  end 
  
  protected 
  def setup_email(user) 
    @recipients  = "#{user.email}" 
    @from        = "admin@emporium-books.com" 
    @subject     = "[Emporium] " 
    @sent_on     = Time.now 
    @body[:user] = user 
  end 
end 
