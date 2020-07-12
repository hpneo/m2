#!/usr/bin/env ruby
require "bundler/setup"
require "dry/cli"
require_relative "./lib/m2/cli/commands/version.rb"
require_relative "./lib/m2/cli/commands/list.rb"
require_relative "./lib/m2/cli/commands/analyze.rb"
require_relative "./lib/m2/cli/commands/timeline.rb"
require_relative "./lib/models/project"

module M2
  module CLI
    module Commands
      extend Dry::CLI::Registry

      register "version", Version, aliases: ["v", "-v", "--version"]
      register "list", List
      register "analyze", Analyze
      register "timeline", Timeline
    end
  end
end

Dry::CLI.new(M2::CLI::Commands).call
