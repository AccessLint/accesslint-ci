require "rest-client"

module Accesslint
  module Ci
    class Commenter
      class CommenterError < StandardError; end

      def self.perform(*args)
        new(*args).perform
      end

      def initialize(errors)
        @errors = errors
      end

      def perform
        RestClient.post(accesslint_service_url, body: payload)
      rescue CommenterError => e
        puts e.message
      end

      private

      attr_reader :errors

      def accesslint_service_url
        @accesslint_service_url ||= URI(
          File.join([
            "https://#{authentication}@www.accesslint.com/api/v1/projects/",
            project_path,
            "pulls",
            pull_request_number,
            "comments",
          ])
        ).to_s
      end

      def authentication
        "#{github_account}:#{ENV.fetch('ACCESSLINT_API_TOKEN')}"
      end

      def pull_request_number
        if ENV["CI_PULL_REQUEST"]
          ENV.fetch("CI_PULL_REQUEST").match(/(\d+)/)[0]
        else
          raise CommenterError.new("Failed to comment: missing CI_PULL_REQUEST.")
        end
      end

      def payload
        { errors: errors }.to_json
      end

      def github_account
        ENV.fetch("CIRCLE_PROJECT_USERNAME")
      end

      def project_path
        [
          github_account,
          ENV.fetch("CIRCLE_PROJECT_REPONAME"),
        ].join("/")
      end
    end
  end
end
