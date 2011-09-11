require 'i18n-one_sky'

module OneSky
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "This generator generates Rails files(initializer and database migration) to use Onesky service"
      
      source_root File.expand_path("../templates", __FILE__)
      
      def install_onesky_active_record
        generate_initializers
        generate_db_migration
      end
      
      protected

      def generate_initializers
        copy_file "onesky.rb", "config/initializers/onesky.rb"
      end
      
      def generate_db_migration
        generate("migration", "translations locale:string key:string value:text")
      end
    end
  end
end
