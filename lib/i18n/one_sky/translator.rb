# this file should only be loaded 

require 'i18n/backend/active_record'

module I18n
  module OneSky
    module Translator
      class Backend < I18n::Backend::ActiveRecord
        include I18n::Backend::Memoize
      end
    end
  end
end