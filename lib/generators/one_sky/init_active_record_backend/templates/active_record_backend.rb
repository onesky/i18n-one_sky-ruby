require 'i18n/backend/active_record'

# flatten and memoize the active record backend
I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Memoize)
I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Flatten)

# chain it into the existing backend
I18n.backend = I18n::Backend::Chain.new(I18n.backend, I18n::Backend::ActiveRecord.new)