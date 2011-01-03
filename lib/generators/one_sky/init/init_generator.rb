module OneSky
  module Generators
    class InitGenerator < ::Rails::Generators::Base
      desc "This generator configures i18n-one_sky for use on this Rails project."
      argument :api_key, :type => :string, :desc => "The API key you got from OneSky"
      argument :api_secret, :type => :string, :desc => "The API secret you got from OneSky"
      argument :project, :type => :string, :desc => "The name of the OneSky project"
      class_option :force, :type => :boolean, :default => false, :desc => "Overwrite if config file already exists"
      @@config_file = [Rails.root.to_s, 'config', 'one_sky.yml'].join('/')

      def remove_config_file
        if File.exists? @@config_file
          if options.force?
            say_status("warning", "config file already exists and is being overwritten.", :yellow)
            remove_file @@config_file
          else
            say_status("error", "config file already exists. Use --force to overwrite.", :red)
            raise "Error: OneSky config file exists."
          end
        end
      end

      def create_config_file
        config_hash = {"api_key" => api_key, "api_secret" => api_secret, "project" => project}
        create_file(@@config_file, config_hash.to_yaml)
        say_status("info", "config file #{@@config_file} created.", :green)
      end
    end
  end
end
