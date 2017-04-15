require "spec_helper"

module Accesslint
  module Ci
    describe Cli do
      context "when comparing to an existing log file" do
        it "comments with the diff between the file and the new results" do
          host = "https://example.com"
          existing_error = "error"
          new_error = "new error"
          previous_log = "tmp/accesslint.diff"
          new_log = "tmp/accesslint.2.log"
          allow(Commenter).to receive(:perform)
          allow(Scanner).to receive(:perform).and_return([existing_error, new_error].join("\n"))
          allow(ReadAccesslintLog).to receive(:perform)
            .with(previous_log).and_return([existing_error])
          allow(File).to receive(:write).with(new_error)
          allow(File).to receive(:open).with(previous_log, anything)

          scanner = Accesslint::Ci::Cli.new(
            [:scan],
            { compare: previous_log, output: previous_log },
          )

          scanner.invoke(:scan, host)

          expect(Commenter).to have_received(:perform).with([new_error])
        end
      end

      context "when there is a diff with new errors" do
        it "posts a comment with the diff" do
          original_branch = ENV["CIRCLE_BRANCH"]
          ENV["CIRCLE_BRANCH"] = "my-branch"
          host = "http://example.com"
          existing = "an error\n"
          latest = existing + "something new!\n"

          allow(Commenter).to receive(:perform)

          allow(LogManager).to receive(:get).
            and_return(existing)

          allow(Scanner).to receive(:perform).
            with(host: host).
            and_return(latest)

          allow(File).to receive(:open).with("tmp/accesslint.diff", anything)

          subject.scan(host)

          expect(Commenter).to have_received(:perform).
            with(["something new!"])

          ENV["CIRCLE_BRANCH"] = original_branch
        end
      end

      context "when there is a diff with fewer errors" do
        it "does not post a comment" do
          original_branch = ENV["CIRCLE_BRANCH"]
          ENV["CIRCLE_BRANCH"] = "my-branch"
          host = "http://example.com"
          existing = "'an error'\n'another error`\n"
          latest = "'an error'\n"

          allow(Commenter).to receive(:perform)

          allow(LogManager).to receive(:get).
            and_return(existing)

          allow(Scanner).to receive(:perform).
            with(host: host).
            and_return(latest)

          subject.scan(host)

          expect(Commenter).not_to have_received(:perform)

          ENV["CIRCLE_BRANCH"] = original_branch
        end
      end

      context "when there is no diff" do
        it "does not post a comment" do
          original_branch = ENV["CIRCLE_BRANCH"]
          ENV["CIRCLE_BRANCH"] = "my-branch"
          host = "http://example.com"
          existing = "an error\n"
          latest = existing

          allow(Commenter).to receive(:perform)

          allow(LogManager).to receive(:get).
            and_return(existing)

          allow(Scanner).to receive(:perform).
            with(host: host).
            and_return(latest)

          subject.scan(host)

          expect(Commenter).not_to have_received(:perform)

          ENV["CIRCLE_BRANCH"] = original_branch
        end
      end

      context "when running on master" do
        it "does not fetch logs or post a comment" do
          original_branch = ENV["CIRCLE_BRANCH"]
          ENV["CIRCLE_BRANCH"] = "master"
          host = "http://example.com"
          latest = "an error\n"
          allow(Commenter).to receive(:perform)
          allow(LogManager).to receive(:get)
          allow(Scanner).to receive(:perform).
            with(host: host).
            and_return(latest)

          subject.scan(host)

          expect(LogManager).not_to have_received(:get)
          expect(Commenter).not_to have_received(:perform)

          ENV["CIRCLE_BRANCH"] = original_branch
        end
      end
    end
  end
end
