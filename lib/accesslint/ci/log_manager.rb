require "net/http"
require "json"

module Accesslint
  module Ci
    class MissingArtifactError < StandardError; end
    class LogManager
      def self.get
        new.get
      end

      def get
        Net::HTTP.get(
          URI(
            "#{artifact_url}?circle-token=#{ENV.fetch('CIRCLE_TOKEN')}"
          )
        )
      rescue MissingArtifactError => e
        puts e.message
        "\n"
      end

      private

      def artifact_url
        if artifacts.any?
          @artifact_url ||= artifacts.each do |artifact|
            if artifact.fetch("path").end_with?("accesslint.log")
              return artifact.fetch("url")
            end
          end
        else
          raise Accesslint::Ci::MissingArtifactError.new(
            puts "No previous accesslint.log available for comparison"
          )
        end
      end

      def artifacts
        @artifacts ||= JSON.parse(
          Net::HTTP.get(
            URI("#{artifacts_uri}?#{query}")
          )
        )
      end

      def artifacts_uri
        URI.join(
          "https://circleci.com/",
          "api/v1/project/",
          project_path,
          "latest/artifacts",
        )
      end

      def project_path
        [
          ENV.fetch("CIRCLE_PROJECT_USERNAME"),
          ENV.fetch("CIRCLE_PROJECT_REPONAME"),
        ].join("/") + "/"
      end

      def query
        URI.encode_www_form([
          ["branch", branch],
          ["filter", "successful"],
          ["circle-token", ENV.fetch("CIRCLE_TOKEN")],
        ])
      end

      def branch
        "master"
      end
    end
  end
end
