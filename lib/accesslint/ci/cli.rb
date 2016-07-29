require "thor"

module Accesslint
  module Ci
    class CLI < Thor
      desc "scan HOST", "scan HOST"
      option :crawl, type: :boolean
      def scan(host)
        existing = LogManager.get.split("\n")
        current = Scanner.perform(host: host, options: options).split("\n")
        diff = current - existing

        if diff.any?
          Commenter.perform(diff)
          puts diff
        end
      end
    end
  end
end
