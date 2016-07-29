require "thor"

module Accesslint
  module Ci
    class CLI < Thor
      desc "scan HOST", "scan HOST"
      option :crawl, type: :boolean
      def scan(host)
        master = LogManager.get.split("\n")
        results = Scanner.perform(host: host, options: options).split("\n")
        diff = results - master
        puts diff
      end
    end
  end
end
