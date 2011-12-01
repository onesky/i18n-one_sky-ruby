require 'i18n'
require 'one_sky'
require 'i18n/one_sky/rails/railtie.rb' if defined? Rails

module I18n
  module OneSky
    class DefaultLocaleMismatchError < StandardError; end
  end
end

require 'i18n/one_sky/simple_client'
require 'i18n/one_sky/version'