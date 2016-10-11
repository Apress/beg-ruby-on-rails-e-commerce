require File.dirname(__FILE__) + '/../test_helper'

class AddressTest < Test::Unit::TestCase
  include ActiveMerchant::Billing
  
  def test_parse
   options = { :address1 => '1234 My Street',
               :address2 => 'Apt 1',
               :company => 'Widgets Inc',
               :city => 'Ottawa',
               :state => 'ON',
               :zip => 'K1C2N6',
               :country => 'Canada',
               :phone => '(555)555-5555'
             } 

    address = Address.new(options)
    options.each{ |k, v| assert_equal v, address.send(k) }
  end
end
