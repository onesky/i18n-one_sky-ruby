require 'i18n/backend/active_record'
require 'i18n/one_sky/client_base'

module I18n
  module OneSky
    # A class to deal with the OneSky apis
    # it encapsulates the logic of I18n::Backend::ActiveRecord
    class ActiveRecordClient < ClientBase

      Translation = I18n::Backend::ActiveRecord::Translation

      def download
        platform_locales.each do |locale|
          locale_code  = locale["locale"]
          local_name   = locale["name"]["local"]
          english_name = locale["name"]["eng"]

          i18n_locale_code = locale_os_to_i18n(locale_code)

          if locale_code == platform_base_locale
            # we skip the base
            next
          else
            yaml = platform.translation.download_yaml(locale_code)
            YAML.load(yaml).each do |code, translations|
              puts "Inserting translations:"
              puts translations.inspect.to_yaml
              translations.each do |key, value|
                Translation.locale(i18n_locale_code).delete_all(["key=?", key])
                Translation.create!(:locale => i18n_locale_code, :key => key.to_s, :value => value)
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
        I18n::Backend::ActiveRecord::Translation.locale(I18n.default_locale).find_each() do |translation|
          phrases[translation.key] = translation.value
        end
        phrases
      end
      memoize :all_phrases

    end
  end
end
