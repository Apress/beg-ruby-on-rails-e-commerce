#!/usr/bin/env ruby
$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__) + '/mocks')
$:.unshift(File.dirname(__FILE__) + '/../lib/active_merchant/billing')
$:.unshift(File.dirname(__FILE__)+ '/extra')

require 'rubygems'
require 'money'
require 'yaml'
require 'net/http'
require 'net/https'
require 'test/unit'
require 'binding_of_caller'
require 'breakpoint'
require 'active_merchant'
require 'method_mock'
require 'openssl'

ActiveMerchant::Billing::Base.mode = :test

module Test
  module Unit
    module Assertions
      def assert_field(field, value)
        clean_backtrace do 
          assert_equal value, @helper.fields[field]
        end
      end

      private
      def clean_backtrace(&block)
        yield
      rescue AssertionFailedError => e
        path = File.expand_path(__FILE__)
        raise AssertionFailedError, e.message, e.backtrace.reject { |line| File.expand_path(line) =~ /#{path}/ }
      end
    end
  end
end
