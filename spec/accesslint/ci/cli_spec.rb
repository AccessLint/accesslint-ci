require "spec_helper"

module Accesslint
  module Ci
    describe CLI do
      context "when there is a diff with new errors" do
        it "posts a comment with the diff" do
          host = "http://example.com"
          existing = "an error\n"
          latest = existing + "something new!\n"

          allow(Commenter).to receive(:perform)

          allow(LogManager).to receive(:get).
            and_return(existing)

          allow(Scanner).to receive(:perform).
            with(host: host, options: {}).
            and_return(latest)

          subject.scan(host)

          expect(Commenter).to have_received(:perform).
            with(["something new!"])
        end
      end

      context "when there is a diff with fewer errors" do
        it "does not post a comment" do
          host = "http://example.com"
          existing = "'an error'\n'another error`\n"
          latest = "'an error'\n"

          allow(Commenter).to receive(:perform)

          allow(LogManager).to receive(:get).
            and_return(existing)

          allow(Scanner).to receive(:perform).
            with(host: host, options: {}).
            and_return(latest)

          subject.scan(host)

          expect(Commenter).not_to have_received(:perform)
        end
      end

      context "when there is no diff" do
        it "does not post a comment" do
          host = "http://example.com"
          existing = "an error\n"
          latest = existing

          allow(Commenter).to receive(:perform)

          allow(LogManager).to receive(:get).
            and_return(existing)

          allow(Scanner).to receive(:perform).
            with(host: host, options: {}).
            and_return(latest)

          subject.scan(host)

          expect(Commenter).not_to have_received(:perform)
        end
      end
    end
  end
end
