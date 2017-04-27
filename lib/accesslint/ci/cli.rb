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

        save_diff

        if skip_ci?
          puts current_errors
        elsif pr? && changes?
          post_comment
        end
      end

      private

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
        normalize_host(errors: new_errors) - normalize_host(errors: existing_diff)
      end

      def new_errors
        normalize_host(errors: current_errors) - normalize_host(errors: baseline_errors)
      end

      def normalize_host(errors:)
        errors.map do |error|
          error.gsub(/localhost:\d+/, "localhost")
        end
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
        elsif circle_ci? && pr?
          @existing_diff ||= LogManager.get.split("\n")
        else
          []
        end
      end

      def previous_diff_file
        options[:compare]
      end

      def circle_ci?
        !skip_ci?
      end

      def save_diff
        WriteAccesslintLog.perform(
          file_name: new_diff_file,
          contents: new_diff.join("\n"),
        )
      end

      def new_diff_file
        options[:outfile] || previous_diff_file || "accesslint.diff"
      end

      def post_comment
        Commenter.perform(new_diff)
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
        File.open(file_name, "w") do |file|
          file.write(contents)
        end
      end
    end
  end
end
