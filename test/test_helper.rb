::RAILS_DEFAULT_LOGGER = @logger unless defined?(::RAILS_DEFAULT_LOGGER)
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'active_support'
