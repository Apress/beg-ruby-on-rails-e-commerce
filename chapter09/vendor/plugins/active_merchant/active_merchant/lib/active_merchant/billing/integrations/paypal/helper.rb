module ActiveMerchant
  module Billing
    module Integrations
      module Paypal
        class Helper < ActiveMerchant::Billing::Integrations::Helper
         CANADIAN_PROVINCES = {  'AB' => 'Alberta',
                                 'BC' => 'British Columbia',
                                 'MB' => 'Manitoba',
                                 'NB' => 'New Brunswick',
                                 'NL' => 'Newfoundland',
                                 'NS' => 'Nova Scotia',
                                 'NU' => 'Nunavut',
                                 'NT' => 'Northwest Territories',
                                 'ON' => 'Ontario',
                                 'PE' => 'Prince Edward Island',
                                 'QC' => 'Quebec',
                                 'SK' => 'Saskatchewan',
                                 'YT' => 'Yukon'
                               } 
          # See https://www.paypal.com/IntegrationCenter/ic_std-variable-reference.html for details on the following options.
          mapping :order, 'item_number'

          def initialize(order, account, options = {})
            super
            add_field('cmd', '_ext-enter')
            add_field('redirect_cmd', '_xclick')
            add_field('quantity', 1)
            add_field('item_name', 'Store purchase')
            add_field('no_shipping', '1')
            add_field('no_note', '1')
            add_field('charset', 'utf-8')
          end

          mapping :amount, 'amount'
          mapping :account, 'business'
          mapping :currency, 'currency_code'
          mapping :notify_url, 'notify_url'
          mapping :return_url, 'return'
          mapping :cancel_return_url, 'cancel_return'
          mapping :invoice, 'invoice'
          mapping :item_name, 'item_name'
          mapping :quantity, 'quantity'
          mapping :no_shipping, 'no_shipping'
          mapping :no_note, 'no_note'

          mapping :customer, :first_name => 'first_name',
                             :last_name  => 'last_name',
                             :email      => 'email',
                             :phone      => 'night_phone_a'

          mapping :billing_address, :city    => 'city',
                                    :address1  => 'address1',
                                    :address2  => 'address2',
                                    :state   => 'state',
                                    :zip     => 'zip',
                                    :country => 'country',
                                    :phone_a  => "night_phone_a",
                                    :phone_b  => "night_phone_b",
                                    :phone_c  => "night_phone_c"
          
           def billing_address(mapping = {})
             
             if mapping.has_key?(:phone)
               phone = mapping.delete(:phone).to_s

               # Whipe all non digits
               phone.gsub!(/\D+/, '')

               # Parse in the us style (555 555 5555) which seems to be the only format paypal supports. Ignore anything before this. 
               if phone =~ /(\d{3})(\d{3})(\d{4})$/
                 add_field(mappings[:billing_address][:phone_a], $1) 
                 add_field(mappings[:billing_address][:phone_b], $2) 
                 add_field(mappings[:billing_address][:phone_c], $3) 
               end
             end
             
             country = map_country_code(mapping.delete(:country))
             if country && country.code(:alpha2).to_s == 'CA'
               province_code = mapping.delete(:state)
               add_field(mappings[:billing_address][:state], CANADIAN_PROVINCES[province_code.upcase]) unless province_code.nil?
             end
             mapping.each do |k, v|
               field = mappings[:billing_address][k]
               add_field(field, v) unless field.nil?
             end
           end


          mapping :tax, 'tax'
          mapping :shipping, 'shipping'
        end
      end
    end
  end
end


