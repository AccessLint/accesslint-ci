require "spec_helper"

module Accesslint
  module Ci
    describe Commenter do
      it "sends a comment to the accesslint service" do
        pull_url = "https://github.com/accesslint/accesslint.com/pull/9001"
        accesslint_service_url = "https://example-user:ABC456@www.accesslint.com/api/v1/projects/accesslint/accesslint-ci/pulls/9001/comments"
        errors = ["new error"]
        body = {
          body: { errors: errors }.to_json
        }
        allow(RestClient).to receive(:get)
        allow(RestClient).to receive(:post)

        ClimateControl.modify(CI_PULL_REQUEST: pull_url) do
          Commenter.perform(errors)
        end

        expect(RestClient).to have_received(:post).with(
          accesslint_service_url,
          body,
        )
      end
    end
  end
end
