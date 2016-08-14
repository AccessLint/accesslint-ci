module Accesslint
  module Ci
    ARTIFACTS_DIR = "tmp/accesslint"
    LOG_FILE = "accesslint.log"
    LOG_PATH = File.join([ARTIFACTS_DIR, LOG_FILE]).freeze
    SITE_DIR = "accesslint-site"
    SITE_PATH = File.join([ARTIFACTS_DIR, SITE_DIR]).freeze
  end
end
