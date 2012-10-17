require 'i18n/backend/active_record'
require 'i18n/one_sky/client_base'

module I18n
  module OneSky
    # A class to deal with the OneSky apis
    # it encapsulates the logic of I18n::Backend::ActiveRecord
    class ActiveRecordClient < ClientBase

      def download
        puts "Downloading translations for I18n Active Record Backend:"

        platform_locales.each do |locale|
          locale_code  = locale["locale"]
          local_name   = locale["name"]["local"]
          english_name = locale["name"]["eng"]

          i18n_locale_code = locale_os_to_i18n(locale_code)

          if false && locale_code == platform_base_locale
            # we skip the base
            next
          else
            yaml = platform.translation.download_yaml(locale_code)
            if yaml.present?
              YAML.load(yaml).each do |code, translations|
                active_record_backend.store_translations(i18n_locale_code, translations)
                puts "  locale: #{i18n_locale_code}, count: #{translation_scope(i18n_locale_code).count}"
              end
            end
          end
        end
      end

      def upload
        upload_phrases(all_phrases)
      end

      # Grab all the keys from the active record store.
      def all_phrases
        phrases = Hash.new
        translation_scope(I18n.default_locale).find_each() do |translation|
          phrases[translation.key] = translation.value
        end
        phrases
      end
      memoize :all_phrases

      protected

      def active_record_backend
        if I18n.backend.is_a?(I18n::Backend::Chain)
          I18n.backend.backends.detect do |backend|
            backend.is_a?(I18n::Backend::ActiveRecord)
          end
        else
          I18n.backend
        end
      end

      def translation_scope(locale)
        I18n::Backend::ActiveRecord::Translation.locale(locale)
      end

    end
  end
end
