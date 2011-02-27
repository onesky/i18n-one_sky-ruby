require 'helpers'

describe "SimpleClient" do

  it "raises an error when initialization values are nil." do
    lambda { @client = I18n::OneSky::SimpleClient.new(:api_key => nil, :api_secret => nil, :project => nil) }.should raise_error ArgumentError
  end

  it "raises an error when OneSky and I18n default locales do not match." do
    I18n.default_locale = :th
    lambda { @client = I18n::OneSky::SimpleClient.new(:project => ENV["ONESKY_SPEC_PROJ"]) }.should raise_error I18n::OneSky::DefaultLocaleMismatchError
  end
end

describe "SimpleClient" do
  include I18nOneSkySpecHelpers

  before do
    @client = create_simple_client_and_load
  end

  describe "#load_phrases" do
    it "should load nested phrases." do
      @client.phrases_nested[:my_pages][:page][:title].should == "My Page Title"
    end

    it "should load flattened phrases." do
      @client.phrases_flat[:'my_pages.page.title'].should == "My Page Title"
    end

    it "should not load excluded sections." do
      @client.phrases_flat[:'number.currency.format.unit'].should be_nil
    end
  end

  describe "#upload_phrases" do
    it "returns true." do
      @client.upload_phrases.should be_true
    end
  end
end

describe "SimpleClient" do
  include I18nOneSkySpecHelpers

  before do
    @client = create_simple_client
  end

  describe "#download_translations" do
    path = [File.dirname(__FILE__), 'data'].join('/')
    it "saves translation files." do
      @client.download_translations(path, true).should be_a_kind_of Array
      Dir.glob("#{path}/*_one_sky.yml").size.should >= 1
    end
  end
end

