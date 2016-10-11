require File.dirname(__FILE__) + '/../test_helper' 
class PaymentTest < Test::Unit::TestCase 
  def test_ups_shipping 
    params = { 
      :zip => 27712, 
      :state => "North Carolina", 
      :sender_zip => 10001, 
      :sender_state => "New York", 
      :weight => 2, 
      :prefs => '../../config/shipping.yml' 
    } 
    ship = Shipping::UPS.new params 
    assert ship.price > 5 
    puts ship.price 
  end 
end