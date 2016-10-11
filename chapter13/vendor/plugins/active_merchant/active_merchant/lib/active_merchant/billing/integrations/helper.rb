module ActiveMerchant
  module Billing
    module Integrations
      class Helper
        attr_reader :fields
        class_inheritable_accessor :service_url
        class_inheritable_hash :mappings
        class_inheritable_accessor :country_format
        self.country_format = :alpha2

        def initialize(order, account, options = {})
          valid_keys = [:amount, :currency]
          options.assert_valid_keys(valid_keys)
          @fields = {}
          self.order = order
          self.account = account
          self.amount = options[:amount]
          self.currency = options[:currency]
        end

        def self.mapping(attribute, options = {})
          self.mappings ||= {}
          self.mappings[attribute] = options
        end

        def add_field(name, value)
          return if name.blank? || value.blank?
          @fields[name.to_s] = value.to_s
        end

        def add_fields(subkey, mapping = {})
          mapping.each do |k, v|
            field = mappings[subkey][k]
            add_field(field, v) unless field.blank?
          end
        end

        def billing_address(mapping = {})
          map_country_code(mapping.delete(:country))
          add_fields(:billing_address, mapping)
        end

        private
        def map_country_code(code)
          return if code.nil?
          country = Country.find(code)
          add_field(mappings[:billing_address][:country], country.code(country_format)) unless country.nil? || mappings[:billing_address][:country].blank?
          country
        end

        def method_missing(method_id, *args)
          method_id = method_id.to_s.gsub(/=$/, '').to_sym
          # Return and do nothing if the mapping was not found. This allows 
          # For easy substitution of the different integrations
          return if mappings[method_id].nil?

          mapping = mappings[method_id]

          if mapping.is_a?(Hash)
            options = args.last.is_a?(Hash) ? args.pop : {}

            mapping.each do |key, field|
              add_field(field, options[key])
            end
          else
            add_field(mapping, args.last)
          end
        end
      end
    end
  end
end
