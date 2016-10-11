require 'test/unit'
require File.dirname(__FILE__) + '/../test_helper'

class EwayTest < Test::Unit::TestCase
  include ActiveMerchant::Billing

  def setup
    @gateway = EwayGateway.new({
      :login => '87654321'
    })

    @creditcard_success = CreditCard.new({
      :number => '4646464646464646',
      :month => (Time.now.month + 1),
      :year => (Time.now.year + 1),
      :first_name => 'Longbob',
      :last_name => 'Longsen'
    })
    
    @creditcard_fail = CreditCard.new({
      :number => '1234567812345678',
      :month => (Time.now.month),
      :year => (Time.now.year),
      :first_name => 'Longbob',
      :last_name => 'Longsen'
    })
    
    @test_params_success = {
      :order_id => '1230123',
      :email => 'bob@testbob.com',
      :address => { :address1 => '47 Bobway, Bobville, WA, Australia',
                    :zip => '2000'
                  } ,
      :description => 'purchased items'
    }
  end
   
  def test_purchase_success    
    assert response = @gateway.purchase(Money.ca_dollar(100), @creditcard_success, @test_params_success)
    assert_instance_of Response, response
    assert_equal '123456', response.authorization
    assert response.success?
    assert_equal '00, TRANSACTION APPROVED', response.params['ewaytrxnerror']
  end

  def test_purchase_error
    assert response = @gateway.purchase(Money.ca_dollar(100), @creditcard_fail, @test_params_success)
    assert_instance_of Response, response
    assert_nil response.authorization
    assert_equal false, response.success?
    assert_not_nil response.params['ewaytrxnerror']
  end
end
