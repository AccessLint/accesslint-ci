require "thor"

module Accesslint
  module Ci
    class Cli < Thor
      desc "scan HOST", "scan HOST"
      option :"skip-ci", type: :boolean
      def scan(host)
        current = Scanner.perform(host: host).split("\n")

        if !options[:"skip-ci"]
          if ENV.fetch("CIRCLE_BRANCH") != "master"
            existing = LogManager.get.split("\n")
            diff = current - existing

            if diff.any?
              Commenter.perform(diff)
            end

            puts diff
          end
        else
          puts current
        end
      end
    end
  end
end
