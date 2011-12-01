# encoding: utf-8

# this spec runs through live api calls
# and requires a real api key for the account
#
#   http://ruby-gem-tests.oneskyapp.com/
#
# before running this test we need to do
#
#   export ONESKY_API_KEY="the key"
#   export ONESKY_API_SECRET="the secret"
#
# the rake spec task skips these test
# you need to run
#
#   rake spec:live
#
require 'spec_helper'

require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => (RUBY_PLATFORM=="java" ? "jdbcsqlite3" : "sqlite3"),
  :database => ":memory:"
)

ActiveRecord::Schema.define(:version => 0) do
  create_table :translations, :force => true do |t|
    t.string  :locale
    t.string  :key
    t.text    :value
    t.text    :interpolations
    t.boolean :is_proc, :default => false

    t.timestamps
  end
end

describe I18n::OneSky::ActiveRecordClient, "LIVE", :live => true do
  
  let(:onesky_api_key)    { ENV["ONESKY_API_KEY"] }
  let(:onesky_api_secret) { ENV["ONESKY_API_SECRET"] }
  let(:project_name)      { "api-test" }
  let(:platform_id)       { 840 }
  let(:platform_code)     { "website" }
  
  let(:english_locale) { "en_US" }
  let(:chinese_locale) { "zh_CN" }
  
  let(:client) do
    I18n::OneSky::ActiveRecordClient.new(
      :api_key     => onesky_api_key,
      :api_secret  => onesky_api_secret,
      :project     => project_name,
      :platform_id => platform_id)
  end
  
  before(:each) do
    I18n.backend = I18n::Backend::ActiveRecord.new
  end
  
  context "download" do

    it "works" do
      client.download
    end
    
    context "with a chained backend" do
      before(:each) do
        I18n.backend = I18n::Backend::Chain.new(I18n::Backend::Simple.new, I18n::Backend::ActiveRecord.new)
      end
      
      it "works" do
        client.upload
      end
    end

  end
  
  context "upload" do
    
    before(:each) do
      I18n::Backend::ActiveRecord::Translation.delete_all
      I18n::Backend::ActiveRecord::Translation.create!(:locale => "en", :key => "test1", :value => "Test 1")
      I18n::Backend::ActiveRecord::Translation.create!(:locale => "en", :key => "test2", :value => "Test 2")
      I18n::Backend::ActiveRecord::Translation.create!(:locale => "en", :key => "number.something", :value => "skip this")
    end
    
    it "works" do
      client.upload
    end
    
    context "with a chained backend" do
      before(:each) do
        I18n.backend = I18n::Backend::Chain.new(I18n::Backend::Simple.new, I18n::Backend::ActiveRecord.new)
      end
      
      it "works" do
        client.upload
      end
    end
    
  end
end