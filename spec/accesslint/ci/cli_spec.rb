require "spec_helper"

module Accesslint
  module Ci
    describe CLI do
      it "outputs logs" do
        host = "http://example.com"
        master = "error\n"
        current_log = "error\nnew error\n"

        allow(LogManager).to receive(:get).
          and_return(master)

        allow(Scanner).to receive(:perform).
          with(host: host, options: {}).
          and_return(current_log)

        expect do
          subject.scan(host)
        end.to output("new error\n").to_stdout
      end
    end
  end
end
