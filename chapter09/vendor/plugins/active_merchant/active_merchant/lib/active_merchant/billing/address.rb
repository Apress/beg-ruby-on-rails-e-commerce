module ActiveMerchant
  module Billing
    class Address
      attr_reader :address1, :address2, :city, :state, :country, :zip, :phone, :company

      def initialize(options = {})
        parse(options)
      end

      private
      def parse(options)
        @address1 = options[:address1]
        @address2 = options[:address2]
        @city = options[:city]
        @state = options[:state]
        @zip = options[:zip]
        @country = options[:country]
        @phone = options[:phone]
        @company = options[:company]
      end
    end
  end
end


