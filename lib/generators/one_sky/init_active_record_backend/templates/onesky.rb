require 'i18n/one_sky/translator'

YAML_BACKEND = I18n.backend
ACTIVE_RECORD_BACKEND = I18n::OneSky::Translator::Backend.new

I18n.backend = I18n::Backend::Chain.new(ACTIVE_RECORD_BACKEND, YAML_BACKEND)