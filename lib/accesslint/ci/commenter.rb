require "rest-client"

module Accesslint
  module Ci
    class Commenter
      def self.perform(*args)
        new(*args).perform
      end

      def initialize(diff)
        @diff = diff
      end

      def perform
        RestClient.post(github_uri, payload)
      end

      private

      attr_reader :diff

      def github_uri
        @github_uri ||= "#{github_host}/issues/#{pull_request_number}/comments"
      end

      def github_host
        URI.join(
          "https://#{auth}@api.github.com/",
          "repos/",
          project_path,
        )
      end

      def auth
        "accesslint-ci:#{ENV.fetch('ACCESSLINT_GITHUB_TOKEN')}"
      end

      def pull_request_number
        if ENV["CI_PULL_REQUEST"]
          ENV.fetch("CI_PULL_REQUEST").match(/(\d+)/)[0]
        else
          pull_requests[0].fetch("number")
        end
      end

      def pull_requests
        @prs ||= JSON.parse(
          RestClient.get(
            "#{github_host}/pulls?head=#{pull_request_head}"
          )
        )
      end

      def pull_request_head
        "#{ENV.fetch('CIRCLE_PROJECT_USERNAME')}:#{ENV.fetch('CIRCLE_BRANCH')}"
      end

      def payload
        {
          body: message,
        }.to_json
      end

      def message
        "Found #{diff.count} new accessibility issues: \n```\n#{snippet}\n```"
      end

      def snippet
        diff.join("\n")
      end

      def project_path
        [
          ENV.fetch("CIRCLE_PROJECT_USERNAME"),
          ENV.fetch("CIRCLE_PROJECT_REPONAME"),
        ].join("/")
      end
    end
  end
end

