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
          wget #{host} 2>&1 \
            --spider \
            --recursive \
            --reject #{file_types_to_ignore} \
            -erobots=off \
            | grep '^--' \
            | awk '{ print $3 }' \
            | sort \
            | uniq \
            | xargs -n1 accesslint \
            >> #{LOG_FILE}
        SHELL
      end

      def file_types_to_ignore
        %w(
          css
          gif
          ico
          jpg
          jpg
          js
          png
          svg
          txt
          woff
        ).join(",")
      end
    end
  end
end
