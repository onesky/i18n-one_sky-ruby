require 'i18n'
require 'one_sky'
require 'i18n/one_sky/rails/railtie.rb' if defined? Rails

module I18n
  module OneSky
    # we only want to load this when i18n-active_record is in use.
    autoload :ActiveRecordClient, 'i18n/one_sky/active_record_client'

    class DefaultLocaleMismatchError < StandardError; end
  end
end

require 'i18n/one_sky/simple_client'
require 'i18n/one_sky/version'