module I18n
  module Onesky
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load "i18n/one_sky/rails/tasks/i18n-one_sky.rake"
      end
    end
  end
end
