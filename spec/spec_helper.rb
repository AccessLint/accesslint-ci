require 'dotenv'

Dotenv.load(".env.test")

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'accesslint/ci'
