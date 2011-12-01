namespace :one_sky do

  desc "Upload phrases for translation to OneSky."
  task :upload_phrases => :environment do
    client = get_client
    puts "Default locale for this Rails app is: #{I18n.default_locale}"
    puts client.load_phrases
    client.upload_phrases
    puts "Phrases uploaded to OneSky. Please ask your translators to... well... get translating."
  end

  desc "Download available translations from OneSky and store as yml files."
  task :download_translations do
    client = get_client
    client.download_translations_yaml(Rails.root.join("config/locales"))
    puts "Translations downloaded and saved to config/locales/*_one_sky.yml files."
  end

  desc "Download available translations from OneSky and stores into Active Record database"
  task :update_activerecord_translations do
    client = get_client
    client.download_translations_active_record
    puts "Translations downloaded and saved to database."
  end

  def get_client
    I18n::OneSky::SimpleClient.from_config(Rails.root.join('config', 'one_sky.yml'))
  end

end
