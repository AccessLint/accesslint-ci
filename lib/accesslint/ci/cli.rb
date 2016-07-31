require "thor"

module Accesslint
  module Ci
    class Cli < Thor
      desc "scan HOST", "scan HOST"
      option :crawl, type: :boolean
      def scan(host)
        current = Scanner.perform(host: host, options: options).split("\n")

        if ENV.fetch("CIRCLE_BRANCH") != "master"
          existing = LogManager.get.split("\n")
          diff = current - existing

          if diff.any?
            Commenter.perform(diff)
            puts diff
          end
        end
      end
    end
  end
end
