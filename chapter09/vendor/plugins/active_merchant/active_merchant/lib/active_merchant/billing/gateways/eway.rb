# Author::    Lucas Carlson  (mailto:lucas@rufy.com)
# Copyright:: Copyright (c) 2005 Lucas Carlson
# License::   Distributes under the same terms as Ruby

require 'rexml/document'

module ActiveMerchant
  module Billing
    # TO USE:
    # First, make sure you have everything setup correctly and all of your dependencies in place with:
    # 
    #   require 'rubygems'
    #   require 'money'
    #   require 'active_merchant'
    #
    # The second line is a require for the 'money' library. Make sure you have it installed with 'gem install money'
    #
    # Using the money library, create a money object. Pass the dollar value in cents. In this case, $10 US becomes 1000.
    #
    #   tendollar = Money.us_dollar(1000)
    #
    # Next, create a credit card object using a TC approved test card.
    #
    #   creditcard = ActiveMerchant::Billing::CreditCard.new({
    #	    :number => '4111111111111111',
    #	    :month => 8,
    #	    :year => 2006,
    #	    :first_name => 'Longbob',
    #     :last_name => 'Longsen'
    #   })
    #   options = {
    #     :login => '87654321',
    #     :order_id => '1230123',
    #     :email => 'bob@testbob.com',
    #     :address => { :address1 => '47 Bobway, Bobville, WA, Australia',
    #                   :zip => '2000'
    #                 }
    #     :description => 'purchased items'
    #   }
    #
    # To finish setting up, create the active_merchant object you will be using, with the eWay gateway. If you have a
    # functional eWay account, replace :login with your account info. 
    #
    #   gateway = ActiveMerchant::Billing::Base.gateway(:eway).new()
    #
    # Now we are ready to process our transaction
    #
    #   response = gateway.purchase(tendollar, creditcard, options)
    #
    # Sending a transaction to TrustCommerce with active_merchant returns a Response object, which consistently allows you to:
    #
    # 1) Check whether the transaction was successful
    #
    #   response.success?
    #
    # 2) Retrieve any message returned by eWay, either a "transaction was successful" note or an explanation of why the
    # transaction was rejected.
    #
    #   response.message
    #
    # 3) Retrieve and store the unique transaction ID returned by eWway, for use in referencing the transaction in the future.
    #
    #   response.authorization
    #
    # This should be enough to get you started with eWay and active_merchant. For further information, review the methods
    # below and the rest of active_merchant's documentation.

    class EwayGateway < Gateway
    	TEST_URL = 'https://www.eway.com.au/gateway/xmltest/testpage.asp'
      LIVE_URL = 'https://www.eway.com.au/gateway/xmlpayment.asp'
      
      attr_reader :url 
      attr_reader :response
      attr_reader :options
	
    	def initialize(options = {})
        requires!(options, :login)
        @options = options
        super
    	end

      def purchase(money, creditcard, options = {})
        requires!(options, :order_id)

        post = {}
        add_creditcard(post, creditcard)
        add_address(post, options)  
        add_customer_data(post, options)
        add_invoice_data(post, options)
        # The request fails if all of the fields aren't present
        add_optional_data(post)
    
        commit(money, post)
      end
    
      def self.supported_cardtypes
        [:visa, :mastercard]
      end
    
      private                       
      def add_creditcard(post, creditcard)
        post[:ewayCardNumber]  = creditcard.number
        post[:ewayCardExpiryMonth]  = sprintf("%.2i", creditcard.month)
        post[:ewayCardExpiryYear] = sprintf("%.4i", creditcard.year)[-2..-1]
        post[:ewayCustomerFirstName] = creditcard.first_name
        post[:ewayCustomerLastName]  = creditcard.last_name
        post[:ewayCardHoldersName] = creditcard.name
      end 

      def add_address(post, options)
        if address = options[:billing_address] || options[:address]
          post[:ewayCustomerAddress]    = address[:address1]
          post[:ewayCustomerPostcode]   = address[:zip]
        end
      end

      def add_customer_data(post, options)
        post[:ewayCustomerEmail] = options[:email] if options.has_key?(:email)
      end
      
      def add_invoice_data(post, options)
        post[:ewayCustomerInvoiceRef] = options[:order_id]
        post[:ewayCustomerInvoiceDescription] = options[:description]
      end

      def add_optional_data(post)
        post[:ewayTrxnNumber] = nil
        post[:ewayOption1] = nil
        post[:ewayOption2] = nil
        post[:ewayOption3] = nil     
      end
      
      def amount(money)          
        cents = money.respond_to?(:cents) ? money.cents : money 
      
        if money.is_a?(String) or cents.to_i <= 0
          raise ArgumentError, 'money amount must be either a Money object or a positive integer in cents.' 
        end

        cents
      end             
 
      def commit(money, parameters)
          
        parameters[:ewayTotalAmount] = amount(money)
        
        if result = test_result_from_cc_number(parameters[:ewayCardNumber])
          return result
        end

        gateway_url = test? ? TEST_URL : LIVE_URL
        data = ssl_post gateway_url, post_data(parameters)
        
        @response = parse(data)

        success = (response[:ewaytrxnstatus] == "True")
        message = message_form(response[:ewaytrxnerror])
    
        Response.new(success, message, @response,
          :authorization => response[:ewayauthcode]
        )      
      end
                                             
      # Parse eway response xml into a convinient hash
      def parse(xml)
        #  "<?xml version=\"1.0\"?>".
        #  <ewayResponse>
        #  <ewayTrxnError></ewayTrxnError>
        #  <ewayTrxnStatus>True</ewayTrxnStatus>
        #  <ewayTrxnNumber>10002</ewayTrxnNumber>
        #  <ewayTrxnOption1></ewayTrxnOption1>
        #  <ewayTrxnOption2></ewayTrxnOption2>
        #  <ewayTrxnOption3></ewayTrxnOption3>
        #  <ewayReturnAmount>10</ewayReturnAmount>
        #  <ewayAuthCode>123456</ewayAuthCode>
        #  <ewayTrxnReference>987654321</ewayTrxnReference>
        #  </ewayResponse>     

        response = {}

        xml = REXML::Document.new(xml)          
        xml.elements.each('//ewayResponse/*') do |node|

          response[node.name.downcase.to_sym] = normalize(node.text)

        end unless xml.root.nil?

        response
      end   

      def post_data(parameters = {})
        parameters[:ewayCustomerID] = @options[:login]
        
        xml   = REXML::Document.new
        root  = xml.add_element("ewaygateway")
        
        parameters.each do |key, value|
          root.add_element(key.to_s).text = value
        end    
        xml.to_s
      end
    
      def message_form(message)
        return '' if message.blank?
        message.gsub(/[^\w]/, ' ').split.join(" ").capitalize
      end

      # Make a ruby type out of the response string
      def normalize(field)
        case field
        when "true"   then true
        when "false"  then false
        when ""       then nil
        when "null"   then nil
        else field
        end        
      end
    end
  end
end
