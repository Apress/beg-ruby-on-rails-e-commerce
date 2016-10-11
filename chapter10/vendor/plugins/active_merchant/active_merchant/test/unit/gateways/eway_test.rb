require File.dirname(__FILE__) + '/../../test_helper'

class EwayTest < Test::Unit::TestCase
  include ActiveMerchant::Billing

  def setup
    @gateway = EwayGateway.new({
      :login => '87654321'
    })

    @creditcard = CreditCard.new({
      :number => '4646464646464646',
      :month => (Time.now.month + 1),
      :year => (Time.now.year + 1),
      :first_name => 'Longbob',
      :last_name => 'Longsen'
    })
    
    @test_params_success = {
      :order_id => '1230123',
      :email => 'bob@testbob.com',
      :address => { :address1 => '47 Bobway, Bobville, WA, Australia',
                    :zip => '2000'
                  },
      :description => 'purchased items'
    }
   
    @xml_test_parameters = {
      :ewayCustomerID => @test_params_success[:login],
      :ewayCustomerInvoiceRef => @test_params_success[:order_id],
      :ewayTotalAmount => 100,
      :ewayCardNumber => @creditcard.number,
      :ewayCardExpiryMonth => sprintf("%.2i", @creditcard.month),
      :ewayCardExpiryYear => sprintf("%.4i", @creditcard.year)[-2..-1],
      :ewayCustomerFirstName => @creditcard.first_name,
      :ewayCustomerLastName => @creditcard.last_name,
      :ewayCustomerEmail => @test_params_success[:email],
      :ewayCustomerAddress => @test_params_success[:address][:address1],
      :ewayCustomerPostcode => @test_params_success[:address][:zip],
      :ewayCustomerInvoiceDescription => @test_params_success[:description],
      :ewayCardHoldersName => @creditcard.name,
      :ewayTrxnNumber => @test_params_success[:order_id],
      :ewayOption1 => '',
      :ewayOption2 => '',
      :ewayOption3 => ''        
    }
  end

  def test_purchase_exceptions
    @creditcard.number = 3 
    
    assert_raise(Error) do
      assert response = @gateway.purchase(Money.ca_dollar(100), @creditcard, @test_params_success)    
    end
  end
       
  def test_amount_style
   assert_equal 1034, @gateway.send(:amount, Money.new(1034))
   assert_equal 1034, @gateway.send(:amount, 1034)
                                                      
   assert_raise(ArgumentError) do
     @gateway.send(:amount, '10.34')
   end
  end
  
  def test_purchase_is_valid_xml
   assert data = @gateway.send(:post_data, @xml_test_parameters)
   assert REXML::Document.new(data)
   assert_equal xml_purchase_fixture.size, data.size
  end  

  def test_ensure_does_not_respond_to_authorize
    assert !@gateway.respond_to?(:authorize)
  end
  
  def test_ensure_does_not_respond_to_capture
    assert !@gateway.respond_to?(:capture)
  end

  private

  def xml_purchase_fixture
    %q{<ewaygateway><ewayCustomerID>87654321</ewayCustomerID><ewayOption3></ewayOption3><ewayCustomerFirstName>Longbob</ewayCustomerFirstName><ewayCustomerAddress>47 Bobway, Bobville, WA, Australia</ewayCustomerAddress><ewayCustomerInvoiceRef>1230123</ewayCustomerInvoiceRef><ewayCardHoldersName>Longbob Longsen</ewayCardHoldersName><ewayTotalAmount>100</ewayTotalAmount><ewayTrxnNumber>1230123</ewayTrxnNumber><ewayCustomerLastName>Longsen</ewayCustomerLastName><ewayCustomerPostcode>2000</ewayCustomerPostcode><ewayCardNumber>4646464646464646</ewayCardNumber><ewayOption1></ewayOption1><ewayCardExpiryMonth>08</ewayCardExpiryMonth><ewayOption2></ewayOption2><ewayCustomerEmail>bob@testbob.com</ewayCustomerEmail><ewayCustomerInvoiceDescription>purchased items</ewayCustomerInvoiceDescription><ewayCardExpiryYear>07</ewayCardExpiryYear></ewaygateway>}
  end
end


