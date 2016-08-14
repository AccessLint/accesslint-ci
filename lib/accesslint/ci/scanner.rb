require "uri"
require "fileutils"

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
        create_site_dir
        create_log_file
        `#{crawl_site}`

        File.read(LOG_PATH)
      end

      private

      attr_reader :host, :options

      def create_site_dir
        if !File.exists?(SITE_PATH)
          FileUtils::mkdir_p(SITE_PATH)
        end
      end

      def create_log_file
        if File.exists?(LOG_PATH)
          FileUtils::rm(LOG_PATH)
        end
      end

      def crawl_site
        <<-SHELL
          wget #{host} \
            --convert-links \
            --html-extension \
            --mirror \
            --directory-prefix #{SITE_PATH} \
            --quiet

          find #{SITE_PATH} -type f -name "*.html" | \
            xargs -n 1 accesslint >> #{LOG_PATH}
        SHELL
      end
    end
  end
end
