require 'langstats/version'
require 'logger'
require 'langstats/langstats_app'
require 'octokit'
require 'json'
require 'langstats/opt_parser'

module Langstats

  ##
  # This class contains the logic to generate stats from an organization name
  class LangstatsApp

    # stores the organization name,
    attr_reader :organization

    # the file name where the result will be stored
    attr_reader :file_name

    # stores the repositories
    attr_reader :repositories

    # stores the repo_languages
    attr_reader :repo_languages

    # stores the organization_total statistics
    attr_reader :organization_statistics

    ##
    # Initialize the client
    # @param options [Hash] a set of options
    def initialize(options = {})
      @organization = options[:organization]

      if @organization.nil? || @organization.empty?
        log 'An organization is required to generate stats'
        exit 1
      end

      @file_name = "#{@organization}_langstats.json"
      @verbose = options[:verbose]
      @logger = Logger.new(STDOUT)

      @client = create_github_client(options)

      @repositories = [] # an array of organization repositories
      @repo_languages = {} # a hash of repo_full_name => Hash of {lang_name => lines_found}
      @raw_sum_statistics = {} # a hash of every language and total sum of lines in all repositories
      @organization_statistics = {} # should contain the normalized percent sum of every language line compared to total lines
    end

    ##
    # Run the complete program to generate the stats
    # and save them to org file
    def generate
      fetch_repositories
      fetch_repos_languages
      calculate_stats

      t = {'organization' => @organization, 'languages' => @organization_statistics}
      write_file(@file_name, JSON.pretty_generate(t))
    end

    ##
    # A method to handle the limit and await for the required seconds until restart processing
    def handle_limit
      rate_limit = @client.rate_limit!
      if rate_limit[:remaining].zero?
        log "Rate limit of (#{rate_limit[:limit]}/hour) has been reached"
        log 'consider running the app with github login and password for (5000 requests/hour)'

        time = rate_limit[:resets_in] + 5 # adding 2 more minutes to be sure
        log "wait for #{time} seconds to resume"
        time.downto(0) do |i|
          log "wait for #{i} seconds to resume"
          sleep 1
        end
      end
    end

    ##
    # Gets all organization repositories from github api then filter out any private or forked repo
    # and collect only the full name {user/org}/{repo}
    def fetch_repositories
      retries ||= 0
      @repositories = @client
                          .organization_repositories(@organization)
                          .select {|repo| !repo['private'] && !repo['fork']}
                          .collect {|repo| repo['full_name']}

      log("Found #{@repositories.count} non forked repos owned by #{@organization}")
      @repositories
    rescue StandardError
      handle_limit
      retry if (retries += 1) < 3
    ensure
      {}
    end

    ##
    # Fetch languages for a repo
    def fetch_repo_languages(repo_full_name)
      retries ||= 0
      languages = @client.languages(repo_full_name).attrs

      languages
    rescue StandardError
      handle_limit
      retry if (retries += 1) < 3
    end

    ##
    # Fetch the languages for linguist api foreach repo
    def fetch_repos_languages
      log('start fetching repo languages from github api')
      i = 1
      @repositories.each do |repo|
        log("#{i}. Fetching languages for #{repo}")
        languages = fetch_repo_languages(repo)
        log("#{i}. Found: #{repo} => #{languages}")
        @repo_languages[repo] = languages
        i += 1
        sleep 1
      end
      @repo_languages
    end

    ##
    # Write data to external file
    def write_file(file_path, file_data)
      File.open(file_path, 'w') {|file| file.write(file_data)}
    end

    ##
    # Uses @repo_languages hash to create sum of each languages in the org repos
    # Then calculates the percent of each language in the total sum
    def calculate_stats
      @raw_sum_statistics = {}

      @repo_languages.each do |_repo, repo_langs|
        repo_langs.each do |lang, value|
          @raw_sum_statistics[lang] = (@raw_sum_statistics.key?(lang) ? @raw_sum_statistics[lang] : 0) + value
        end
      end

      total_sum = @raw_sum_statistics.values.sum

      @organization_statistics = @raw_sum_statistics.map do |lang, value|
        percent_of_total = ((value / total_sum.to_f) * 100).round(2)

        [lang, percent_of_total]
      end.to_h

      log("Total Stats Calculated : #{@organization_statistics}")

      @organization_statistics
    end

    ##
    # Getting options and create a github client using authentication or not
    def create_github_client (options)
      Octokit.configure {|kit| kit.auto_paginate = true}

      if !options[:username].nil? && !options[:username].empty?
        !options[:password].nil? && !options[:password].empty?

        options[:client] = Octokit::Client.new \
          login: options[:username],
          password: options[:password]
      else
        options[:client] = Octokit::Client.new
      end
    end

    ##
    # log a message only if verbose is active
    def log(message)
      @logger.info message if @verbose
    end

    private :fetch_repo_languages, :fetch_repositories, :fetch_repos_languages, :log, :create_github_client
  end
end
