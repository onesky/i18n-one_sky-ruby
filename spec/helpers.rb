$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'i18n-one_sky'

module I18nOneSkySpecHelpers
  def create_simple_client
    raise "Please set environment variables: ONESKY_API_KEY, ONESKY_API_SECRET and ONESKY_SPEC_PROJ (default: i18noneskyspec) before running spec." unless [ENV["ONESKY_API_KEY"], ENV["ONESKY_API_SECRET"]].all?
    I18n.default_locale = :en
    client = I18n::OneSky::SimpleClient.new(
      :api_key => ENV["ONESKY_API_KEY"], 
      :api_secret => ENV["ONESKY_API_SECRET"], 
      :project => ENV["ONESKY_SPEC_PROJ"] || "i18noneskyspec"
    )
  end

  def create_simple_client_and_load
    client = create_simple_client
    client.load_phrases([File.dirname(__FILE__), "data"].join('/'))
    client 
  end  
end
