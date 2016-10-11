require 'net/http'
require 'net/https'
require 'active_merchant/billing/response'

module ActiveMerchant
  module Billing
    # The Gateway class is the base class for all ActiveMerchant gateway
    # implementations. The list of gateway functions that concrete
    # gateway classes can and should implement include the following:
    # 
    #  * authorize(money, creditcard, options = {})
    #  * purchase(money, creditcard, options = {})
    #  * capture(money, authorization, options = {})
    #  * credit(money, identification, options = {})  
    #  * recurring(money, identification, options = {})  
    #  * store(money, identification, options = {})  
    #  * unstore(money, identification, options = {})  
    #  
    class Gateway
      include PostsData
      include RequiresParameters
      
      # Return the matching gateway for the provider
      # * <tt>bogus</tt>: BogusGateway - Does nothing ( for testing)
      # * <tt>moneris</tt>: MonerisGateway
      # * <tt>authorized_net</tt>: AuthorizedNetGateway
      # * <tt>trust_commerce</tt>: TrustCommerceGateway
      # 
      #   ActiveMerchant::Base.gateway('moneris').new
      def self.gateway(name)
        ActiveMerchant::Billing.const_get("#{name.to_s.downcase}_gateway".camelize)
      end                        
             
      # Does this gateway support credit cards of the passed type?
      def self.supports?(type)
        supported_cardtypes.include?(type.intern)
      end
                                                                  
      # Get a list of supported credit card types for this gateway
      def self.supported_cardtypes
        []
      end                                 
    
      # Initialize a new gateway 
      # 
      # See the documentation for the gateway you will be using to make sure there
      # are no other required options
      def initialize(options = {})    
        @ssl_strict = options[:ssl_strict] || false
      end
                                     
      # Are we running in test mode?
      def test?
        Base.gateway_mode == :test
      end
            
      protected
      def name
        self.class.name.scan(/\:\:(\w+)Gateway/).flatten.first
      end
      
      def test_result_from_cc_number(number)
        return false unless test?
        
        case number.to_s
        when '1', 'success' 
          Response.new(true, 'Successful test mode response', {:receiptid => '#0001'}, :test => true, :authorization => '5555')
        when '2', 'failure' 
          Response.new(false, 'Failed test mode response', {:receiptid => '#0001'}, :test => true)
        when '3', 'error' 
          raise Error, 'big bad exception'
        else 
          false
        end
      end
    end
  end
end
