require 'spec_helper'
require 'webmock/rspec'
require 'json'
require_relative '../lib/langstats/langstats_app'

describe Langstats::LangstatsApp do
  describe 'when empty organization' do
    it "should exit the app" do

      expect do
        langstats = Langstats::LangstatsApp.new
      end.to raise_error(SystemExit)
    end
  end

  describe 'when fetching orgnaization repositories' do
    it 'should return fullname of every non private repo' do
      langstats = Langstats::LangstatsApp.new(organization: 'skroutz')

      file = File.read('spec/responses_sample/skroutz_repos_response.txt')

      stub_request(:get, 'https://api.github.com/orgs/skroutz/repos?per_page=100')
        .with(headers: {
                'Accept' => 'application/vnd.github.v3+json',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Content-Type' => 'application/json',
                'User-Agent' => 'Octokit Ruby Gem 4.8.0'
              })
        .to_return(file)

      repositories = langstats.send(:fetch_repositories)

      expect(repositories).to_not be_nil
      expect(repositories.count).to eq(32)
      expect(repositories).to contain_exactly('skroutz/selectorablium', 'skroutz/elasticsearch-analysis-greeklish', 'skroutz/oauth2-rails-demo', 'skroutz/oauth2-oscommerce-module', 'skroutz/oauth2-joomla-component', 'skroutz/wappalyzer-ruby', 'skroutz/oauth2-joomla-module', 'skroutz/oauth2-joomla-plugin', 'skroutz/elasticsearch-skroutz-greekstemmer', 'skroutz/css-style-guide', 'skroutz/javascript-style-guide', 'skroutz/hasEvent', 'skroutz/developer.skroutz.gr', 'skroutz/mnlp', 'skroutz/string_metric', 'skroutz/greek_stemmer', 'skroutz/turkish_stemmer', 'skroutz/elasticsearch-analysis-turkishstemmer', 'skroutz/analytics.js', 'skroutz/clj-skroutz', 'skroutz/biskoto', 'skroutz/skroutz.rb', 'skroutz/greeklish', 'skroutz/skroutz.ex', 'skroutz/skroutz-analytics-woocommerce', 'skroutz/cogy', 'skroutz/cogy-bundle', 'skroutz/AdapterDelegatesSample', 'skroutz/elasticsearch-dynamic-word-delimiter', 'skroutz/rafka', 'skroutz/rafka-rb', 'skroutz/kafka-cluster-testbed')

      expect(langstats.repositories).to_not be_nil
      expect(langstats.repositories.count).to eq(32)
      expect(langstats.repositories).to contain_exactly('skroutz/selectorablium', 'skroutz/elasticsearch-analysis-greeklish', 'skroutz/oauth2-rails-demo', 'skroutz/oauth2-oscommerce-module', 'skroutz/oauth2-joomla-component', 'skroutz/wappalyzer-ruby', 'skroutz/oauth2-joomla-module', 'skroutz/oauth2-joomla-plugin', 'skroutz/elasticsearch-skroutz-greekstemmer', 'skroutz/css-style-guide', 'skroutz/javascript-style-guide', 'skroutz/hasEvent', 'skroutz/developer.skroutz.gr', 'skroutz/mnlp', 'skroutz/string_metric', 'skroutz/greek_stemmer', 'skroutz/turkish_stemmer', 'skroutz/elasticsearch-analysis-turkishstemmer', 'skroutz/analytics.js', 'skroutz/clj-skroutz', 'skroutz/biskoto', 'skroutz/skroutz.rb', 'skroutz/greeklish', 'skroutz/skroutz.ex', 'skroutz/skroutz-analytics-woocommerce', 'skroutz/cogy', 'skroutz/cogy-bundle', 'skroutz/AdapterDelegatesSample', 'skroutz/elasticsearch-dynamic-word-delimiter', 'skroutz/rafka', 'skroutz/rafka-rb', 'skroutz/kafka-cluster-testbed')
    end
  end

  describe 'when fetching repository languages' do
    it 'should return the languages' do
      options = {
        organization: 'skroutz'
      }

      file = File.read('spec/responses_sample/selectorablium_languages_response.txt')

      langstats = Langstats::LangstatsApp.new(options)

      stub_request(:get, 'https://api.github.com/repos/skroutz/selectorablium/languages?per_page=100')
        .with(headers: {
                'Accept' => 'application/vnd.github.v3+json',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Content-Type' => 'application/json',
                'User-Agent' => 'Octokit Ruby Gem 4.8.0'
              })
        .to_return(file)

      langs = langstats.send(:fetch_repo_languages, 'skroutz/selectorablium')

      expect(langs).to_not be_nil
      expect(langs).to eq(CoffeeScript: 60_285, JavaScript: 17_872, CSS: 5293)
    end
  end

  describe 'when fetching multiple repo languages' do
    it 'should add all repo languages to hash by repo full name' do
      options = {
        organization: 'skroutz'
      }
      langstats = Langstats::LangstatsApp.new(options)
      langstats.instance_variable_set('@repositories', ['skroutz/selectorablium', 'skroutz/elasticsearch-analysis-greeklish'])

      fileselectoabliumtest = File.read('spec/responses_sample/selectorablium_languages_response.txt')
      fileelastictest = File.read('spec/responses_sample/elasticsearch-analysis-greeklish.txt')

      stub_request(:get, 'https://api.github.com/repos/skroutz/selectorablium/languages?per_page=100')
        .with(headers: {
                'Accept' => 'application/vnd.github.v3+json',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Content-Type' => 'application/json',
                'User-Agent' => 'Octokit Ruby Gem 4.8.0'
              })
        .to_return(fileselectoabliumtest)

      stub_request(:get, 'https://api.github.com/repos/skroutz/elasticsearch-analysis-greeklish/languages?per_page=100')
        .with(headers: {
                'Accept' => 'application/vnd.github.v3+json',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Content-Type' => 'application/json',
                'User-Agent' => 'Octokit Ruby Gem 4.8.0'
              })
        .to_return(fileelastictest)

      langstats.send(:fetch_repos_languages)

      expect(langstats.repo_languages.key?('skroutz/selectorablium')).to be_truthy
      expect(langstats.repo_languages.key?('skroutz/elasticsearch-analysis-greeklish')).to be_truthy

      expect(langstats.repo_languages['skroutz/selectorablium']).to eq(CoffeeScript: 60_285, JavaScript: 17_872, CSS: 5293)
      expect(langstats.repo_languages['skroutz/elasticsearch-analysis-greeklish']).to eq(Java: 31_504)
    end
  end

  describe 'when calculating stats' do
    it 'should combine all stats from repo_languages to total_statistics per language' do
      options = {
        organization: 'skroutz'
      }
      langstats = Langstats::LangstatsApp.new(options)
      langstats.instance_variable_set('@repo_languages',
                                      'skroutz/selectorablium' => {
                                        CoffeeScript: 100, JavaScript: 50, CSS: 30
                                      },
                                      'skroutz/elasticsearch-analysis-greeklish' => {
                                        CoffeeScript: 100,
                                        Java: 100,
                                        Html: 1
                                      })

      langstats.send(:fetch_repos_languages)

      langstats.send(:calculate_stats)

      expect(langstats.instance_variable_get('@raw_sum_statistics')).to eq(CoffeeScript: 200, JavaScript: 50, CSS: 30, Java: 100, Html: 1)
      expect(langstats.organization_statistics).to eq(CoffeeScript: 52.49, JavaScript: 13.12, CSS: 7.87, Java: 26.25, Html: 0.26)
    end
  end

  # describe 'when running the app' do
  #   it "should create a file name skroutz_langstats.json" do
  #     options = {
  #         organization: 'skroutz'
  #     }
  #     langstats = Langstats::LangstatsApp.new(options)
  #
  #     file = File.read('spec/responses_sample/skroutz_repos_mini.txt')
  #
  #     stub_request(:get, 'https://api.github.com/orgs/skroutz/repos?per_page=100')
  #         .with(headers: {
  #             'Accept' => 'application/vnd.github.v3+json',
  #             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
  #             'Content-Type' => 'application/json',
  #             'User-Agent' => 'Octokit Ruby Gem 4.8.0'
  #         })
  #         .to_return(file)
  #   end
  # end
end
