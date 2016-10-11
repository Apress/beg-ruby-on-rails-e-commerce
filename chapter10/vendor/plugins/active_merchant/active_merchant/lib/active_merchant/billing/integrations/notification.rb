module ActiveMerchant
  module Billing
    module Integrations
      class Notification
        attr_accessor :params
        attr_accessor :raw

        def initialize(post)
          empty!
          parse(post)
        end

        def status
          raise NotImplementedError, "Must implement this method in the subclass"
        end

        # the money amount we received in X.2 decimal.
        def gross
          raise NotImplementedError, "Must implement this method in the subclass"
        end

        def gross_cents
          (gross.to_f * 100.0).round
        end

        # This combines the gross and currency and returns a proper Money object. 
        # this requires the money library located at http://dist.leetsoft.com/api/money
        def amount
          return Money.new(gross_cents, currency) rescue ArgumentError
          return Money.new(gross_cents) # maybe you have an own money object which doesn't take a currency?
        end

        # reset the notification. 
        def empty!
          @params  = Hash.new
          @raw     = ""      
        end

        private

        # Take the posted data and move the relevant data into a hash
        def parse(post)
          @raw = post
          for line in post.split('&')    
            key, value = *line.scan( %r{^(\w+)\=(.*)$} ).flatten
            params[key] = CGI.unescape(value)
          end
        end
      end
    end
  end
end
