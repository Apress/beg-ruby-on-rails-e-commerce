class UserObserver < ActiveRecord::Observer
  def after_save(user) 
    UserNotifier.deliver_forgot_password(user) if user.password_forgotten 
  end
end