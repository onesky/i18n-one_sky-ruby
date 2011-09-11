module OneSky
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "This generator generates Rails files(initializer and database migration) to use Onesky service"
      
      def install_onesky_active_record
        generate_initializers
        generate_db_migration
      end
      
      protected

      def generate_initializers
        initializer("onesky.rb") do
          require "i18n/onesky/translator"

          I18n.backend = I18n::Backend::Chain.new(I18n::Onesky::Translator::Backend.new, I18n.backend)
        end
      end
      
      def generate_db_migration
        generate("migration", "translations locale:string key:string value:text")
      end
    end
  end
end
