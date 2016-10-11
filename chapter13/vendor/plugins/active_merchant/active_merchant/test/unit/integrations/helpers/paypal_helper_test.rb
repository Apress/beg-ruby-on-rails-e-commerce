require File.dirname(__FILE__) + '/../../../test_helper'

class PaypalHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def setup
    @helper = Paypal::Helper.new(1,'cody@example.com', :amount => 500, :currency => 'CAD')
    @url = 'http://example.com'
  end
  
  def test_static_fields
    assert_field 'cmd', '_ext-enter'
    assert_field 'redirect_cmd', '_xclick'
    assert_field 'quantity', '1'
    assert_field 'item_name', 'Store purchase'
    assert_field 'no_shipping', '1'
    assert_field 'no_note', '1'
    assert_field 'charset', 'utf-8'
  end

  def test_basic_helper_fields
    assert_field 'item_number', '1'
    assert_field 'business', 'cody@example.com'
    assert_field 'amount', '500'
    assert_field 'currency_code', 'CAD'
  end

  def test_invoice
    @helper.invoice = 'Shopify shirt'
    assert_field 'invoice', 'Shopify shirt'
  end

  def test_notification_url
    @helper.notify_url = @url
    assert_field 'notify_url', @url
  end

  def test_return_url
    @helper.return_url = @url
    assert_field 'return', @url
  end
  
  def test_cancel_return_url
    @helper.cancel_return_url = @url
    assert_field 'cancel_return', @url
  end
 
  def test_customer_fields 
    @helper.customer :first_name => 'Cody', 
                     :last_name => 'Fauser',
                     :email => 'cody@example.com',
                     :phone => '(555)555-5555'

    assert_field 'first_name', 'Cody'
    assert_field 'last_name', 'Fauser'
    assert_field 'email', 'cody@example.com'
    assert_field 'night_phone_a', '(555)555-5555'
  end

  def test_billing_address
    @helper.billing_address :country => 'CA',
                            :address1 => '1 My Street',
                            :city => 'Ottawa',
                            :zip => '90210'

    assert_field 'country', 'CA'
    assert_field 'address1', '1 My Street'
    assert_field 'zip', '90210' 
  end

  def test_phone_parsing
    @helper.billing_address :phone => '111-222-3333'

    assert_field 'night_phone_a', '111'
    assert_field 'night_phone_b', '222'
    assert_field 'night_phone_c', '3333'
  end
  
  
  def test_province
    @helper.billing_address :country => 'CA',
                            :state => 'On'

    assert_field 'country', 'CA'
    assert_field 'state', 'Ontario'
  end

  def test_state
    @helper.billing_address :country => 'US',
                            :state => 'TX'

    assert_field 'country', 'US'
    assert_field 'state', 'TX'
  end
  
  def test_shipping
    @helper.shipping '7.99'
    assert_field 'shipping', '7.99'
  end

  def test_tax
    @helper.tax '14.99'
    assert_field 'tax', '14.99'
  end

  def test_country_code
    @helper.billing_address :country => 'CAN'
    assert_field 'country', 'CA'
  end

  def test_setting_invalid_address_field
    fields = @helper.fields.dup
    @helper.billing_address :street => 'My Street'
    assert_equal fields, @helper.fields
  end
  
  def test_setting_item_name
    @helper.item_name = 'Really Cool Gizmo'
    assert_field 'item_name', 'Really Cool Gizmo'
  end

  def test_setting_quantity
    @helper.quantity = '10'
    assert_field 'quantity', '10'
  end
  
  def test_setting_no_shipping
    @helper.no_shipping = '0'
    assert_field 'no_shipping', '0'
  end
  
  def test_setting_no_note
    @helper.no_note = '0'
    assert_field 'no_note', '0'
  end
end
