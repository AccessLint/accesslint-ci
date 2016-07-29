require "uri"

module Accesslint
  module Ci
    class Scanner
      def self.perform(*args)
        new(*args).perform
      end

      def initialize(host:, options: {})
        @host = host
        @options = options
      end

      def perform
        `#{command}`
        File.read("tmp/accesslint.log")
      end

      private

      attr_reader :host, :options

      def command
        <<-SHELL
          wget #{host} \
            --convert-links \
            --html-extension \
            --mirror \
            --directory-prefix tmp/accesslint-site/ \
            --quiet

          find tmp/accesslint-site/ -type f -name "*.html" | \
            xargs -n 1 -P 5 accesslint >> tmp/accesslint.log
        SHELL
      end
    end
  end
end
