module OneSky
  module Generators
    class InitGenerator < ::Rails::Generators::Base
      desc "This generator configures i18n-one_sky for use on this Rails project."

      argument :api_key,     :type => :string, :desc => "The API key you got from OneSky"
      argument :api_secret,  :type => :string, :desc => "The API secret you got from OneSky"
      argument :project,     :type => :string, :desc => "The name of the OneSky project"
      argument :platform_id, :type => :string, :desc => "The id of the OneSky platform"

      class_option :force,   :type => :boolean, :default => false, :desc => "Overwrite if config file already exists"

      CONFIG_PATH = File.join(Rails.root.to_s, 'config', 'one_sky.yml')

      def remove_config_file
        if File.exists? CONFIG_PATH
          if options.force?
            say_status("warning", "config file already exists and is being overwritten.", :yellow)
            remove_file @@config_file
          else
            say_status("error", "config file already exists. Use --force to overwrite.", :red)
            raise "Error: OneSky config file exists."
          end
        end
      end

      def config_hash
        {"api_key" => api_key, "api_secret" => api_secret, "project" => project, "platform_id" => platform_id.to_i}
      end

      def create_config_file
        create_file(CONFIG_PATH, config_hash.to_yaml)
        say_status("info", "config file #{CONFIG_PATH} created.", :green)
      end
    end
  end
end
