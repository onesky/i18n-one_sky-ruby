require 'i18n'
require 'one_sky'
require 'i18n-one_sky/rails/railtie.rb' if defined? Rails

module I18n
  module OneSky
    autoload :SimpleClient, 'i18n-one_sky/simple_client'
    class DefaultLocaleMismatchError < StandardError; end
  end
end
