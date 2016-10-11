class Order < ActiveRecord::Base
  require 'payment/authorize_net' 
  include ActiveMerchant::Billing
  
  attr_protected :id, :customer_ip, :status, :error_message, :updated_at, :created_at
  attr_accessor :card_type, :card_number, :card_expiration_month, :card_expiration_year, :card_verification_value 
  
  has_many :order_items 
  has_many :books, :through => :order_items
  
  validates_size_of :order_items, :minimum => 1 
  validates_length_of :ship_to_first_name, :in => 2..255 
  validates_length_of :ship_to_last_name, :in => 2..255 
  validates_length_of :ship_to_address, :in => 2..255 
  validates_length_of :ship_to_city, :in => 2..255 
  validates_length_of :ship_to_postal_code, :in => 2..255 
  validates_length_of :ship_to_country, :in => 2..255 
  
  validates_length_of :phone_number, :in => 7..20 
  validates_length_of :customer_ip, :in => 7..15 
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i 
  validates_inclusion_of :status, :in => %w(open processed closed failed) 
  validates_inclusion_of :card_type, :in => ['Visa', 'MasterCard', 'Discover'], :on => :create 
  validates_length_of :card_number, :in => 13..19, :on => :create 
  validates_inclusion_of :card_expiration_month, :in => %w(1 2 3 4 5 6 7 8 9 10 11 12), :on => :create 
  validates_inclusion_of :card_expiration_year, :in => %w(2006 2007 2008 2009 2010), :on => :create 
  validates_length_of :card_verification_value, :in => 3..4, :on => :create

  def total 
    order_items.inject(0) {|sum, n| n.price * n.amount + sum} 
  end
    
  def process 
    if closed? raise "Order is closed" 
    begin
      # process_with_active_merchant 
      process_woth_payment_gem
    rescue => e 
      logger.error("Order #{id} failed with error message #{e}") 
      self.error_message = 'Error while processing order' 
      self.status = 'failed' 
    end 
    save! 
    self.status == 'processed' 
  end
  
  def close 
    self.status = 'closed' 
    save! 
  end
  
  def closed? 
    status == 'closed' 
  end
  
  private
  
  # The paypal method
  
  # def process_with_active_merchant 
  #   Base.gateway_mode = :test 
  #   gateway = PaypalGateway.new( 
  #     :login     => 'business_account_login', 
  #     :password  => 'business_account_password', 
  #     :cert_path => File.join(File.dirname(__FILE__), "../../config/paypal") 
  #   ) 
  #   gateway.connection.wiredump_dev = STDERR 
  #   
  #   creditcard = CreditCard.new( 
  #     :type                => card_type, 
  #     :number              => card_number, 
  #     :verification_value  => card_verification_value, 
  #     :month               => card_expiration_month, 
  #     :year                => card_expiration_year, 
  #     :first_name          => ship_to_first_name, 
  #     :last_name           => ship_to_last_name 
  #   ) 
  # 
  #   # Buyer information 
  #   params = { 
  #     :order_id => self.id, 
  #     :email => email, 
  #     :address => { :address1 => ship_to_address, 
  #                   :city => ship_to_city, 
  #                   :country => ship_to_country, 
  #                   :zip => ship_to_postal_code 
  #                 } , 
  #     :description => 'Books', 
  #     :ip => customer_ip 
  #   } 
  #   response = gateway.purchase(total, creditcard, params) 
  #   if response.success? 
  #     self.status = 'processed' 
  #   else 
  #     self.error_message = response.message 
  #     self.status = 'failed' 
  #   end 
  # end 
  
  # The authorize.net method
  
  def process_with_active_merchant 
    creditcard = ActiveMerchant::Billing::CreditCard.new({ 
      :type => card_type, 
      :number => card_number, 
      :month => card_expiration_month, 
      :year => card_expiration_year, 
      :first_name => ship_to_first_name, 
      :last_name => ship_to_last_name 
    }) 
    if creditcard.valid? 
      gateway = AuthorizedNetGateway.new({ 
        :login => "your login", 
        :password => "your password" 
      }) 
      options = { 
        :card_code => card_verification_value, 
        :name => ship_to_first_name + " " + ship_to_last_name, 
        :address => ship_to_address, 
        :city => ship_to_city, 
        :zip => ship_to_postal_code, 
        :country => ship_to_country, 
        
        :email => email, 
        :phone => phone_number, 
        :customer_ip => customer_ip 
      } 
      response = gateway.purchase(total, creditcard, options) 
      
      if response.success? 
        self.status = 'processed' 
      else 
        self.status = 'failed' 
        self.error_message = response.message 
      end 
    else 
      self.status = 'failed' 
      self.error_message = 'Invalid credit card' 
    end 
  end 
  
  def process_with_payment_gem 
    transaction = Payment::AuthorizeNet.new( 
      :prefs       => "#{RAILS_ROOT}/config/payment.yml", 
      :login => 'your login', 
      :password => 'your password', 
      :url => 'https://test.authorize.net/gateway/transact.dll', 
      :amount => total, 
      :card_number => card_number, 
      :expiration  => "#{card_expiration_month}/#{card_expiration_year}", 
      :first_name  => ship_to_first_name, 
      :last_name   => ship_to_last_name, 
      :ship_to_last_name => ship_to_last_name, 
      :ship_to_first_name => ship_to_first_name, 
      :ship_to_address => ship_to_address, 
      :ship_to_city => ship_to_city, 
      :ship_to_zip => ship_to_postal_code, 
      :ship_to_country => ship_to_country, 
      :customer_ip => customer_ip, 
      :invoice_num => id 
     ) 
    begin 
      transaction.submit 
      logger.debug( 
        "Card processed successfully. 
          Response codes: 
            authorization: #{transaction.authorization} 
            result code: #{transaction.result_code} 
            avs code: #{transaction.avs_code} 
            transaction id: #{transaction.transaction_id} 
            md5: #{transaction.md5} 
            cvv2 response: #{transaction.cvv2_response} 
            cavv response: #{transaction.cavv_response}" 
      ) 
      self.status = 'processed' 
    rescue => e 
      self.error_message = transaction.error_message 
      self.status = 'failed' 
    end 
  end 
  
  
end