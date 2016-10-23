require "spec_helper"

module Accesslint
  module Ci
    describe LogManager do
      describe ".get" do
        context "with existing logs from a master build" do
          it "returns the existing logs" do
            allow(RestClient).to receive(:get).
              with("https://example.com/accesslint.log?circle-token=ABC123").
              and_return("1\n2\n")

            allow(RestClient).to receive(:get).
              with("https://circleci.com/api/v1/project/accesslint/accesslint-ci/latest/artifacts?branch=master&filter=successful&circle-token=ABC123").
              and_return([
                path: "accesslint.log",
                url: "https://example.com/accesslint.log",
            ].to_json)

            log = LogManager.get

            expect(log).not_to be_empty
          end
        end

        context "with no existing logs" do
          it "returns a newline" do
            allow(RestClient).to receive(:get).
              with("https://circleci.com/api/v1/project/accesslint/accesslint-ci/latest/artifacts?branch=master&filter=successful&circle-token=ABC123").
              and_return([].to_json)

            log = LogManager.get

            expect(log).to eq "\n"
          end
        end

        context "with no existing artifacts" do
          it "returns a newline" do
            allow(RestClient).to receive(:get).
              with("https://circleci.com/api/v1/project/accesslint/accesslint-ci/latest/artifacts?branch=master&filter=successful&circle-token=ABC123").
              and_raise(RestClient::NotFound.new)

            log = LogManager.get

            expect(log).to eq "\n"
          end
        end
      end
    end
  end
end
