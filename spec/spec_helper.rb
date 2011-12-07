$:.unshift File.expand_path('../../lib', __FILE__)
require 'i18n-one_sky'

def spec_root_path
  File.expand_path(File.dirname(__FILE__))
end

def fixture_path(file_name)
  File.join(spec_root_path, "fixtures", "files", file_name)
end
