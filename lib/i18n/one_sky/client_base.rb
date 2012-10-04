require 'memoist'

module I18n
  module OneSky
    # A base class to deal with the OneSky apis
    #
    # Its subclasses;
    #   SimpleClient
    #   ActiveRecordClient
    #
    # encapsulate specifics of uploading/downloading for the I18n backends;
    #   I18n::Backend::Simple
    #   I18n::Backend::ActiveRecord
    class ClientBase
      extend Memoist

      # The base OneSky project. Gives you low-level access to the API gem.
      attr_reader :client, :project, :platform

      # Load the client from the one_sky.yml file (installed by `rails generate one_sky:init_generator`)
      def self.from_config(config_path)
        if self.config_exists?(config_path)
          self.new(load_config(config_path))
        else
          self.from_env
        end
      end

      # Load the client from environment variables.
      def self.from_env
        self.new(
          :api_key     => ENV["ONESKY_API_KEY"],
          :api_secret  => ENV["ONESKY_API_SECRET"],
          :project     => ENV["ONESKY_PROJECT"],
          :platform_id => ENV["ONESKY_PLATFORM_ID"])
      end

      # Load the one_sky.yml file.
      # first parsing it as ERB
      # to enable dynamic config;
      #
      #   api_key:     <%= ENV["ONESKY_API_KEY"] %>
      #   api_secret:  <%= ENV["ONESKY_API_SECRET"] %>
      #   project:     <%= ENV["ONESKY_PROJECT"] %>
      #   platform_id: <%= ENV["ONESKY_PLATFORM_ID"] %>
      #
      def self.load_config(config_path)
        require 'erb'
        YAML::load(ERB.new(File.read(config_path)).result).symbolize_keys
      end

      # check if the path exists
      def self.config_exists?(config_path)
        File.exist?(config_path)
      end

      # When you initialize a client inside a Rails project, it will take the OneSky configuration variables supplied when you called rails generate one_sky:init.
      # Outside of Rails, credentials are expected to come from environment variables: ONESKY_API_KEY, ONESKY_API_SECRET, ONESKY_PROJECT.
      # You can override these defaults by providing a hash of options:
      # * api_key
      # * api_secret
      # * project
      def initialize(options = {})
        verify_options!(options)

        @client   = ::OneSky::Client.new(options[:api_key], options[:api_secret])
        @project  = @client.project(options[:project])
        @platform = @project.platform(options[:platform_id])
      end

      # Check the configuration of our client.
      def verify!
        verify_platform!
        verify_default_locale!
      end

      # The default locale for the platform.
      def platform_base_locale
        platform_details["base_locale"]
      end

      # An array of codes. eg. ["en_US", "zh_CN"]
      def platform_locale_codes
        platform_locales.map do |hash|
          hash["locale"]
        end
      end

      # Cached call to load the locales for a platform.
      def platform_locales
        @platform.locales
      end
      memoize :platform_locales

      # Cached call to load the details for the platform.
      def platform_details
        @platform_details ||= @platform.details
      end
      memoize :platform_details

      # Remove all Rails i18n keys as of December 2nd 2011.
      #  https://github.com/svenfuchs/rails-i18n/blob/a4fb3d3dbb1a05a2adc82355c934e81eea67e3a1/rails/locale/en-GB.yml
      SKIP_KEYS_REGEXP = /^(date|time|support|number|datetime|helpers|errors|activerecord)#{Regexp.escape(I18n.default_separator)}/

      protected

      def skip_key?(key)
        key =~ SKIP_KEYS_REGEXP
      end

      def upload_phrases(phrases)
        skip, upload = phrases.partition{ |string_key, string| skip_key?(string_key) || string.blank? }

        puts "Uploading strings:"
        puts "  count: #{upload.length}"
        platform.translation.input_phrases(upload)
      end

      REQUIRED_KEYS = [:api_key, :api_secret, :project, :platform_id]

      REQUIRED_KEYS_MESSAGE = <<-MESSAGE
One Sky API Version 2 works differently to Version 1.

Translations are now attached to a "platform", as well as a project.
Eg. there may be one for Android, one for IOS, and one for Web.

In order to authenticate for this gem, you must now specify the following;

* ONE_SKY_API_KEY
* ONE_SKY_API_SECRET
* ONE_SKY_PROJECT      -- the name of the project
* ONE_SKY_PLATFORM_ID  -- the numeric id of the platform

Try running
  rails generate one_sky:init

again to regenerate your config.
      MESSAGE

      def verify_options!(options)
        missing_keys = REQUIRED_KEYS - options.keys
        unless missing_keys.empty?
          raise ::ArgumentError, REQUIRED_KEYS_MESSAGE
        end
      end

      def verify_platform!
        # call the api for the platform
        # this'll raise if there's an authentication problem
        platform_details
      end

      def verify_default_locale!
        if I18n.default_locale.to_s.downcase != locale_os_to_i18n(platform_base_locale).to_s.downcase
          raise DefaultLocaleMismatchError, "I18n and OneSky have different default locale settings. #{I18n.default_locale} <> #{platform_base_locale}"
        end
      end

      # i18n has a default locale of :en
      # while OneSky uses "en_US"
      def locale_os_to_i18n(locale)
        case locale
        when "en_US"
          "en"
        else
          locale
        end
      end

      def locale_i18n_to_os(locale)
        case locale.to_s
        when "en"
          "en_US"
        else
          locale.to_s
        end
      end
    end
  end
end