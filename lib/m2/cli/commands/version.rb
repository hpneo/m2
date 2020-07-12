require "dry/cli"

module M2
  module CLI
    module Commands
      class Version < Dry::CLI::Command
        desc "Print version"

        def call(*)
          puts "0.1.0"
        end
      end
    end
  end
end