require "spec_helper"

module Accesslint
  module Ci
    describe Cli do
      context "when comparing to an existing log file" do
        it "comments with the diff between the file and the new results" do
          host = "https://example.com"

          baseline = "http://localhost:123 | my error"
          current = "http://localhost:456 | my error\nhttp://localhost:456 | new error"

          baseline_log_file = "tmp/accesslint.log"
          previous_diff_file = "tmp/accesslint.diff"

          allow(Commenter).to receive(:perform)
          allow(Scanner).to receive(:perform).and_return(current)

          allow(ReadAccesslintLog).to receive(:perform)
            .with(baseline_log_file).and_return([baseline])
          allow(ReadAccesslintLog).to receive(:perform)
            .with(previous_diff_file).and_return([])

          scanner = Accesslint::Ci::Cli.new(
            [host],
            {
              compare: previous_diff_file,
              base: baseline_log_file,
            },
          )

          scanner.invoke(:scan)

          expect(Commenter).to have_received(:perform).with(["http://localhost | new error"])
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

          scanner = Accesslint::Ci::Cli.new([host])

          scanner.invoke(:scan)

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
