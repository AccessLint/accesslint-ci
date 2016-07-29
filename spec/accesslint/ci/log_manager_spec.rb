require "spec_helper"

module Accesslint
  module Ci
    describe LogManager do
      describe ".get" do
        it "returns logs from the most recent successful master CI build" do
          expect(LogManager.get).not_to be_empty
        end
      end
    end
  end
end
