require "bundler"
Bundler.setup

%w[rack rack/contrib net/http mime/types app].each {|f| require f }

use Rack::Head
use Rack::Deflater
use Rack::ETag
use Rack::ConditionalGet
run App.new("http://tjsingleton.name")