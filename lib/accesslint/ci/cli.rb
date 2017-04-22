require "thor"

module Accesslint
  module Ci
    class Cli < Thor
      desc "scan HOST", "scan HOST"
      option :"base", type: :string
      option :"compare", type: :string
      option :"hosted", type: :boolean
      option :"outfile", type: :string
      option :"skip-ci", type: :boolean
      def scan(host)
        @host = host

        if skip_ci?
          puts current_errors
          return
        elsif pr? && changes?
          save_diff
          post_comment
        end
      end

      no_commands do
        attr_reader :host

        def skip_ci?
          options[:"skip-ci"]
        end

        def pr?
          ENV.fetch("CIRCLE_BRANCH") != "master"
        end

        def changes?
          new_diff.any?
        end

        def new_diff
          new_errors - existing_diff
        end

        def new_errors
          current_errors - baseline_errors
        end

        def current_errors
          @current_errors ||= Scanner.perform(host: host).split("\n")
        end

        def baseline_errors
          if baseline_file
            @baseline_errors ||= ReadAccesslintLog.perform(baseline_file)
          else
            []
          end
        end

        def baseline_file
          options[:base]
        end

        def existing_diff
          if previous_diff_file
            @existing_diff ||= ReadAccesslintLog.perform(previous_diff_file)
          else
            @existing_diff ||= LogManager.get.split("\n")
          end
        end

        def previous_diff_file
          options[:compare]
        end

        def save_diff
          WriteAccesslintLog.perform(
            file_name: new_diff_file,
            contents: new_diff.join("\n"),
          )
        end

        def new_diff_file
          options[:outfile] || previous_diff_file
        end

        def post_comment
          Commenter.perform(new_diff)
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

    class WriteAccesslintLog
      def self.perform(file_name:, contents:)
        if File.exist?(file_name)
          File.open(file_name, "w") do |file|
            file.write(contents)
          end
        end
      end
    end
  end
end
