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
require 'tmpdir'
require 'yaml'

describe I18n::OneSky::SimpleClient, "LIVE", :live => true do
  
  let(:onesky_api_key)    { ENV["ONESKY_API_KEY"] }
  let(:onesky_api_secret) { ENV["ONESKY_API_SECRET"] }
  let(:project_name)      { "api-test" }
  let(:platform_id)       { 840 }
  let(:platform_code)     { "website" }
  
  let(:english_locale) { "en_US" }
  let(:chinese_locale) { "zh_CN" }
  
  let(:client) do
    I18n::OneSky::SimpleClient.new(
      :api_key     => onesky_api_key,
      :api_secret  => onesky_api_secret,
      :project     => project_name,
      :platform_id => platform_id)
  end
  
  context "download" do

    let(:yaml_path) { Dir.tmpdir }
    
    def yaml_files
      Dir.glob(yaml_path+"/*.yml")
    end

    before(:each) do
      # delete any pre-existing yml files.
      File.delete(*yaml_files)
    end

    it "creates yaml files" do
      yaml_files.should be_empty
      
      client.download(yaml_path)
      
      yaml_files.should_not be_empty
    end
    
    it "creates a yaml file for the chinese locale." do
      client.download(yaml_path)
      
      chinese_file = yaml_files.detect{|f| f.end_with?("#{chinese_locale}_one_sky.yml") }
      yaml = YAML.load(File.read(chinese_file))
      yaml.keys.should == [chinese_locale]
    end

  end
  
  context "upload" do
    
    let(:yaml_path) { File.expand_path("../fixtures/files", __FILE__) }
    
    it "uploads any yaml files in the path" do
      client.upload(yaml_path)
    end
  end
  
    
end