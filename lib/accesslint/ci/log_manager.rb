require "rest-client"
require "json"

module Accesslint
  module Ci
    class MissingArtifactError < StandardError; end
    class LogManager
      def self.get
        new.get
      end

      def get
        RestClient.get(
          "#{artifact_url}?circle-token=#{ENV.fetch('CIRCLE_TOKEN')}"
        )
      rescue MissingArtifactError => e
        puts e.message
        "\n"
      end

      private

      def artifact_url
        artifact = artifacts.first do |artifact|
          artifact["path"].end_with?("accesslint.log")
        end

        if artifact
          @artifact_url ||= artifact.fetch("url")
        else
          raise MissingArtifactError.new("No existing logs for comparison.")
        end
      end

      def artifacts
        @artifacts ||= JSON.parse(RestClient.get("#{artifacts_uri}?#{query}"))
      rescue RestClient::NotFound
        raise MissingArtifactError.new("No existing artifacts.")
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
        ENV.fetch("ACCESSLINT_MASTER_BRANCH", "master")
      end
    end
  end
end
