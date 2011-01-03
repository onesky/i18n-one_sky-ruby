namespace :one_sky do
  desc "Upload phrases for translation to OneSky."
  task :upload_phrases => :environment do
    client = I18n::OneSky::SimpleClient.new
    puts "Default locale for this Rails app is: #{I18n.default_locale}"
    puts client.load_phrases
    client.upload_phrases
    puts "Phrases uploaded to OneSky. Please ask your translators to... well... get translating."
  end

  desc "Download available translations from OneSky."
  task :download_translations do
    client = I18n::OneSky::SimpleClient.new
    client.download_translations
    puts "Translations downloaded and saved to config/locales/*_one_sky.yml files."
  end
end
