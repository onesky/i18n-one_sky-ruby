require 'i18n'
require 'one_sky'
require 'i18n-one_sky/rails/railtie.rb' if defined? Rails
require 'i18n/backend/active_record' if defined? ActiveRecord

module I18n
  module OneSky
    autoload :SimpleClient, 'i18n-one_sky/simple_client'
    class DefaultLocaleMismatchError < StandardError; end

    if defined?(ActiveRecord)
      module Translator
        class Backend < I18n::Backend::ActiveRecord
          include I18n::Backend::Memoize

          def initialize
            download_translations
            super
          end

          def download_translations
            client = I18n::OneSky::SimpleClient.new
            client.download_translations(:active_record => true)
          end
        end
      end
    end
  end
end
