require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < Test::Unit::TestCase
  fixtures :orders

  def test_that_we_can_create_a_valid_order
    order = Order.new( 
      # Contact Information 
      :email => 'abcdef@gmail.com', 
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
      :card_verification_value => '333' 
    ) 
    # Private parts 
    order.customer_ip = '10.0.0.1' 
    order.status = 'processed' 
    order.order_items << OrderItem.new( 
      :book_id => 1, 
      :price => 100.666, 
      :amount => 13 
    ) 
    assert order.save 
    order.reload 
    
    assert_equal 1, order.order_items.size 
    assert_equal 100.666, order.order_items[0].price 
  end 

  def test_that_validation_works 
    order = Order.new 
    assert_equal false, order.save 
    # An order should have at least one order item 
    assert order.errors.on(:order_items) 
    assert_equal 15, order.errors.size 
    # Contact Information 
    assert order.errors.on(:email) 
    assert order.errors.on(:phone_number) 
    # Shipping Address    
    assert order.errors.on(:ship_to_first_name) 
    assert order.errors.on(:ship_to_last_name) 
    assert order.errors.on(:ship_to_address) 
    assert order.errors.on(:ship_to_city) 
    assert order.errors.on(:ship_to_postal_code) 
    assert order.errors.on(:ship_to_country) 
    # Billing Information    
    assert order.errors.on(:card_type) 
    assert order.errors.on(:card_number) 
    assert order.errors.on(:card_expiration_month) 
    assert order.errors.on(:card_expiration_year) 
    assert order.errors.on(:card_verification_value) 

    assert order.errors.on(:customer_ip) 
  end 

end
