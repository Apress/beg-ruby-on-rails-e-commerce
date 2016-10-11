require "#{File.dirname(__FILE__)}/../test_helper" 
class AuthenticationTest < ActionController::IntegrationTest
  def setup 
    User.create(:login => "george", 
                :email => "george@emporium.com", 
                :password => "cheetah", 
                :password_confirmation => "cheetah") 
  end 
  
  def test_successful_login 
    george = enter_site(:george) 
    george.tries_to_go_to_admin 
    george.logs_in_successfully("george", "cheetah") 
  end 
  
  def test_failing_login 
    harry = enter_site(:harry) 
    harry.tries_to_go_to_admin 
    harry.attempts_login_and_fails("scott", "tiger") 
  end 
  
  private 
  
  module BrowsingTestDSL 
    include ERB::Util 
    attr_writer :name 
    def tries_to_go_to_admin 
      get "/admin/book/new" 
      assert_response :redirect 
      assert_redirected_to "/account/login" 
    end
    
    def logs_in_successfully(login, password) 
      post_login(login, password) 
      assert_response :redirect 
      assert_redirected_to "/admin/book/new" 
    end 
    
    def attempts_login_and_fails(login, password) 
      post_login(login, password) 
      assert_response :success 
      assert_template "account/login" 
      assert_equal "Incorrect login!", flash[:notice] 
    end 
    
    private 
    
    def post_login(login, password) 
      post "/account/login", :login => login, :password => password 
    end
  end 
  
  def enter_site(name) 
    open_session do |session| 
      session.extend(BrowsingTestDSL) 
      session.name = name 
      yield session if block_given? 
    end 
  end 
end 
