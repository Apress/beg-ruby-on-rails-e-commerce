require "#{File.dirname(__FILE__)}/../test_helper"

class CheckoutTest < ActionController::IntegrationTest
  fixtures :authors, :publishers, :books
  
  def test_that_empty_cart_shows_error_message
    get '/checkout'
    assert_response :redirect
    assert_redirected_to :controller => "catalog"
    assert_equal "Your shopping cart is empty! Please add something to it before proceeding to checkout.", flash[:notice]
  end

  def test_that_placing_an_order_works 
    post '/cart/add', :id => 1 
    get '/checkout' 
    assert_response :success 
    assert_tag :tag => 'legend', :content => 'Contact Information' 
    assert_tag :tag => 'legend', :content => 'Shipping Address' 
    assert_tag :tag => 'legend', :content => 'Billing Information'
    
    post '/checkout/place_order', :order => { 
      # Contact Information 
      :email => 'abce@gmail.com', 
      :phone_number => '3498438943843', 
      # Shipping Address 
      :ship_to_first_name => 'Hallon', 
      :ship_to_last_name => 'Saft', 
      :ship_to_address => 'Street', 
      :ship_to_city => 'City',
      :ship_to_postal_code => 'Code', 
      :ship_to_country => 'Iceland', 
      # Billing Information 
      :card_type => 'Visa', 
      :card_number => '4007000000027', 
      :card_expiration_month => '1', 
      :card_expiration_year => '2009', 
      :card_verification_value => '333', 
    } 

    assert_response :redirect
    assert_redirected_to '/checkout/thank_you' 
  end
end
