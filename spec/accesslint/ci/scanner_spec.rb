require "spec_helper"

module Accesslint
  module Ci
    describe Scanner do
      describe ".perform" do
        it "returns results" do
          host = "http://example.com"

          expect(
            Scanner.perform(host: host)
          ).to include "<html> element must have a valid lang attribute"
        end
      end
    end
  end
end
