require "uri"
require "fileutils"

module Accesslint
  module Ci
    SITE_DIR = "tmp/accesslint-site".freeze
    LOG_FILE = "tmp/accesslint.log".freeze

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

        File.read(LOG_FILE)
      end

      private

      attr_reader :host, :options

      def create_site_dir
        if !File.exists?(SITE_DIR)
          FileUtils::mkdir_p(SITE_DIR)
        end
      end

      def create_log_file
        if File.exists?(LOG_FILE)
          FileUtils::rm(LOG_FILE)
        end
      end


      def crawl_site
        <<-SHELL
          wget #{host} \
            --convert-links \
            --html-extension \
            --mirror \
            --directory-prefix #{SITE_DIR} \
            --quiet

          find #{SITE_DIR} -type f -name "*.html" | \
            xargs -n 1 -P 5 accesslint >> #{LOG_FILE}
        SHELL
      end
    end
  end
end
