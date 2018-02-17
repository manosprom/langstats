require 'spec_helper'
require_relative '../lib/langstats/opt_parser'

context Langstats::OptParser do
  describe 'when empty args' do
    it 'should return default option' do
      ARGV = []
      options = Langstats::OptParser.parse(ARGV)

      expect(options[:verbose]).to be_falsey
      expect(options[:organization]).to eq('')
      expect(options[:username]).to eq('')
      expect(options[:password]).to eq('')
    end
  end

  describe 'when options set' do
    it 'should return all options' do
      ARGV.replace ["-o", "skroutz", "-v", "-u", "test@test.com", "-p", "testtest"]
      options = Langstats::OptParser.parse(ARGV)
      expect(options[:verbose]).to be_truthy
      expect(options[:organization]).to eq('skroutz')
      expect(options[:username]).to eq('test@test.com')
      expect(options[:password]).to eq('testtest')
    end
  end

  describe 'when validate options' do
    it 'should throw if no organization' do
      expect do
        ARGV = []
        options = Langstats::OptParser.parse(ARGV)
        Langstats::OptParser.validate_opts(options)
      end.to raise_error(SystemExit)
    end
  end
end