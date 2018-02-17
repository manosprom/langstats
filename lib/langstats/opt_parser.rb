require 'optparse'
require 'optparse/time'
require 'ostruct'

module Langstats
  ##
  # This class contains the program options parsing
  class OptParser

    ##
    # Parse args to options
    def self.parse(args)
      options = OpenStruct.new
      options[:verbose] = false
      options[:organization] = ''
      options[:username] = ''
      options[:password] = ''

      optparser = OptionParser.new do |opts|
        options[:verbose] = false
        opts.on('-v', '--verbose', 'Print info messages') do |v|
          options[:verbose] = v
        end

        opts.on('-o', '--organization MANDATORY', String, 'Organization to scan repos') do |organization|
          options.organization = organization
        end

        opts.on('-u', '--username username', String, 'User login') do |username|
          options[:username] = username
        end

        opts.on('-p', '--password password', String, 'User password') do |password|
          options[:password] = password
        end

        opts.on('-h', '--help', 'Display help') do |_h|
          puts opts
          exit 0
        end
      end

      optparser.parse!(args)
      options
    end

    ##
    # Validate current options
    def self.validate_opts(options)
      if options[:organization].nil? || options[:organization].empty?
        puts 'please set an --organization'
        exit 1
      end
    end
  end
end
