module I18n
  module OneSky
    # This class is the bridge between the OneSky service and the I18n Simple backend.
    # It takes the phrases defined in I18n's default locale and uploads them to OneSky for translation.
    # Then it downloads available translations and saves them as Simple backend's YAML files.
    # A regular workflow would then look like:
    #   initialize -> load_phrases -> upload_phrases -> download_translations
    class SimpleClient
      include I18n::Backend::Flatten

      attr_reader :phrases_nested, :phrases_flat
      # The base OneSky project. Gives you low-level access to the API gem.
      attr_reader :project

      # When you initialize a client inside a Rails project, it will take the OneSky configuration variables supplied when you called rails generate one_sky:init.
      # Outside of Rails, credentials are expected to come from environment variables: ONESKY_API_KEY, ONESKY_API_SECRET, ONESKY_PROJECT.
      # You can override these defaults by providing a hash of options:
      # * api_key
      # * api_secret
      # * project
      def initialize(options = {})
        options = default_options.merge!(options)
        @project = ::OneSky::Project.new(options[:api_key], options[:api_secret], options[:project])
        #@one_sky_locale = @project.details["base_locale"].gsub('_', '-')
        @one_sky_locale = @project.details["base_locale"]
        check_default_locales_match
        @one_sky_languages = @project.languages
      end

      # This will load the phrases defined for I18n's default locale.
      # If not a Rails project, manually supply the path where the I18n yml or rb files for located.
      def load_phrases(path=nil)
        backend = I18n.backend.is_a?(I18n::Backend::Chain) ? I18n.backend.backends.last : I18n.backend

        if defined?(Rails)
          backend.load_translations
        else
          raise ArgumentError, "Please supply the path where locales are located." unless path
          path = path.chop if path =~ /\/$/
          backend.load_translations(*Dir.glob("#{path}/**/*.{yml,rb}"))
        end
        
        @phrases_nested = backend.instance_variable_get("@translations")[I18n.default_locale]

        # Flatten the nested hash.
        flat_keys = flatten_translations(I18n.default_locale, @phrases_nested, true, false)

        # Remove those "supporting/generic" i18n entities that we're not sending to OneSky.
        # Those that are found in the rails-i18n github repository.
        # Eg. number, datetime, activemodel, etc.
        # Note: This doesn't handle FLATTEN_SEPARATOR other than '.' yet.
        patterns = %w{number datetime activemodel support activerecord date time errors helpers}.inject([]) { |o,e| o << Regexp.new("^#{e}(\\..*)?$") }
        @phrases_flat = flat_keys.reject { |k,v| patterns.find { |e| k.to_s =~ e } }
      end

      # Once you've loaded the default locale's phrases, call this method to send them to OneSky for translation.
      def upload_phrases
        load_phrases unless @phrases_flat

        batch_requests = @phrases_flat.inject([]) do |o,(k,v)| 
          # ToDo: Materialize ALL CLDR plural tags if at least one is present for a leaf node.
          o << {:string_key => k, :string => v}
        end

        @project.input_bulk(batch_requests)
      end

      # When your translators are done, call this method to download all available translations and save them as Simple backend *.yml files.
      # Outside of Rails, manually supply the path where downloaded files should be saved.
      def download_translations(path=nil, download_base_locale=false, use_active_record=false)
        if defined?(Rails)
          path ||= [Rails.root.to_s, "config", "locales"].join("/")
        else
          raise ArgumentError, "Please supply the path where locales are to be downloaded." unless path
          path = path.chop if path =~ /\/$/
        end

        output = @project.output

        # Let's ignore other hash nodes from the API and just rely on the string keys we sent during upload. Prefix with locale.
        @translations = Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }
        output.map do |k0,v0| # Page level
          v0.map do |k1, v1| # Locale level
            v1.map do |k2, v2| # string key level
              @translations[k1][[k1, k2].join('.')] = v2 
            end
          end 
        end

        if use_active_record
          @translations.map { |k,v| save_locale(k, v) unless (k.to_s == @one_sky_locale and !download_base_locale)}
        else 
          # Delete all existing one_sky translation files before downloading a new set.
          File.delete(*Dir.glob("#{path}/*_one_sky.yml"))
        
          # Process each locale and save to file
          @translations.map { |k,v| save_locale(k, v, :filename => "#{path}/#{k}_one_sky.yml") unless (k.to_s == @one_sky_locale and !download_base_locale)}
        end
      end

      protected

      def save_locale(lang_code, phrases, options={})
        nested = to_nested_nodes(phrases)

        lang = @one_sky_languages.find { |e| e["locale"] == lang_code }

        if options[:filename]
          filename = options[:filename]
          File.open(filename, 'w') do |f| 
            f.puts "# PLEASE DO NOT EDIT THIS FILE."
            f.puts "# This was downloaded from OneSky. Log in to your OneSky account to manage translations on their website."
            f.puts "# Language code: #{lang['locale']}"
            f.puts "# Language name: #{lang['local_name']}"
            f.puts "# Language English name: #{lang['eng_name']}"
            f.print(nested.to_yaml)
          end 
          filename
        else
          
          lang = @one_sky_languages.find { |e| e["locale"] == lang_code }
          
          nested.each do |k, values|            
            values.each do |value|
              I18n.backend.store_translations(k, value[0] => value[1])
            end
          end
        end
      end
      
      def to_nested_nodes(phrases)
        nested = Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }
        phrases.each do |k,v|
          node = nested
          parts = k.split('.')
          parts.each_with_index { |segment,i| node[segment]; i == parts.size - 1 ? node[segment] = v : node = node[segment] }
        end
        
        nested
      end

      def default_options
        options = {:api_key => ENV["ONESKY_API_KEY"], :api_secret => ENV["ONESKY_API_SECRET"], :project => ENV["ONESKY_PROJECT"]}
        
        if defined?(Rails)
          config_file = [Rails.root.to_s, 'config', 'one_sky.yml'].join('/')

          options = YAML.load_file(config_file).symbolize_keys if File.exists?(config_file)
        end
        
        options
      end

      def check_default_locales_match
        # Special case: i18n "en" is "en-us".
        i18n_default_locale = I18n.default_locale == :en ? "en_us" : I18n.default_locale.to_s.downcase
        raise DefaultLocaleMismatchError, "I18n and OneSky have different default locale settings. #{I18n.default_locale.to_s} <> #{@one_sky_locale}" if i18n_default_locale != @one_sky_locale.downcase 
      end
    end
  end
end

