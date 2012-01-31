namespace :one_sky do

  desc "Upload phrases for translation to OneSky."
  task :upload => :environment do
    simple_client.upload(locales_path)
    puts "Phrases uploaded to OneSky. Please ask your translators to... well... get translating."
  end

  desc "Download available translations from OneSky and store as yml files."
  task :download => :environment do
    simple_client.download(locales_path)
    puts "Translations downloaded and saved to config/locales/*_one_sky.yml files."
  end

  namespace :active_record do
    #
    # desc "Upload."
    # task :upload => :environment do
    #   active_record_client.upload
    # end

    desc "Download available translations from OneSky and stores into Active Record database."
    task :download => :environment do
      active_record_client.download
    end

    desc "Clear all translations from the database translation store."
    task :clear => :environment do
      count = I18n::Backend::ActiveRecord::Translation.delete_all
      puts "deleted #{count} translations from the database."
    end

  end

  #
  # namespace :heroku do
  #
  #   desc "Update the translations on heroku"
  #   task :update => :environment do
  #     heroku_client.download
  #   end
  #
  # end

  def heroku_client
    I18n::OneSky::ActiveRecordClient.from_env
  end

  def active_record_client
    I18n::OneSky::ActiveRecordClient.from_config(one_sky_config)
  end

  def simple_client
    I18n::OneSky::SimpleClient.from_config(one_sky_config)
  end

  def locales_path
    Rails.root.join("config/locales")
  end

  def one_sky_config
    Rails.root.join('config', 'one_sky.yml')
  end

end
