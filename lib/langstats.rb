require 'langstats/version'
require 'logger'
require 'langstats/langstats_app'
require 'octokit'
require 'json'
require 'langstats/opt_parser'

##
# A module to retrieve language statistics for all public not forced repos of an organization
module Langstats
  options = OptParser.parse(ARGV)
  langstatsApp = LangstatsApp.new(options)
  langstatsApp.generate
end
