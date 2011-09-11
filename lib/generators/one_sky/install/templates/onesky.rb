I18n.backend = I18n::Backend::Chain.new(I18n::OneSky::Translator::Backend.new, I18n.backend)

client = I18n::OneSky::SimpleClient.new
client.download_translations(:active_record => true)