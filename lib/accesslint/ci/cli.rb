require "thor"

module Accesslint
  module Ci
    class Cli < Thor
      desc "scan HOST", "scan HOST"
      option :"skip-ci", type: :boolean
      option :"hosted", type: :boolean
      option :"compare", type: :string
      option :"outfile", type: :string
      def scan(host)
        current = Scanner.perform(host: host).split("\n")

        if !options[:"skip-ci"]
          existing = []

          if ENV.fetch("CIRCLE_BRANCH") != "master"
            if options[:compare]
              existing = ReadAccesslintLog.perform(options[:compare])
            elsif !options[:hosted]
              existing = LogManager.get.split("\n")
            end

            diff = current - existing

            puts diff

            if diff.any?
              outfile = options[:outfile] || "tmp/accesslint.diff"

              File.open(outfile, "w") do |file|
                file.write(diff.join("\n"))
              end

              Commenter.perform(diff)
            end
          end
        else
          puts current
        end
      end
    end

    class ReadAccesslintLog
      def self.perform(file_name)
        if File.exist?(file_name)
          File.open(file_name, "r") { |file| file.read }.split("\n")
        else
          []
        end
      end
    end
  end
end
