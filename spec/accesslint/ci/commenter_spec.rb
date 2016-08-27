require "spec_helper"

module Accesslint
  module Ci
    describe Commenter do
      it "posts a comment to GitHub" do
        original_pull_request = ENV["CI_PULL_REQUEST"]
        ENV["CI_PULL_REQUEST"] = "https://github.com/accesslint/accesslint-ci/pull/9001"

        allow(RestClient).to receive(:get).
          with("https://accesslint-ci:ABC456@api.github.com/repos/accesslint/accesslint-ci/pulls?head=accesslint:#{ENV.fetch('CIRCLE_BRANCH')}").
          and_return([ { number: 1 } ].to_json)
        allow(RestClient).to receive(:post)

        Commenter.perform(["my diff"])

        expect(RestClient).to have_received(:post).with(
          "https://accesslint-ci:ABC456@api.github.com/repos/accesslint/accesslint-ci/issues/9001/comments",
          { body: "Found 1 new accessibility issues: \n```\nmy diff\n```" }.to_json
        )

        ENV["CI_PULL_REQUEST"] = original_pull_request
      end

      context "when CI_PULL_REQUEST is set" do
        it "uses the number from CI_PULL_REQUEST" do
          original_pull_request = ENV["CI_PULL_REQUEST"]
          ENV["CI_PULL_REQUEST"] = "https://github.com/accesslint/accesslint-ci/pull/9001"
          allow(RestClient).to receive(:post)

          Commenter.perform(["my diff"])

          expect(RestClient).to have_received(:post).with(
            "https://accesslint-ci:ABC456@api.github.com/repos/accesslint/accesslint-ci/issues/9001/comments",
            { body: "Found 1 new accessibility issues: \n```\nmy diff\n```" }.to_json
          )

          ENV["CI_PULL_REQUEST"] = original_pull_request
        end
      end

      context "when running on master" do
        it "uses the number from CI_PULL_REQUEST" do
          original_pull_request = ENV["CI_PULL_REQUEST"]
          ENV["CI_PULL_REQUEST"] = "https://github.com/accesslint/accesslint-ci/pull/9001"
          allow(RestClient).to receive(:post)

          Commenter.perform(["my diff"])

          expect(RestClient).to have_received(:post).with(
            "https://accesslint-ci:ABC456@api.github.com/repos/accesslint/accesslint-ci/issues/9001/comments",
            { body: "Found 1 new accessibility issues: \n```\nmy diff\n```" }.to_json
          )

          ENV["CI_PULL_REQUEST"] = original_pull_request
        end
      end
    end
  end
end
