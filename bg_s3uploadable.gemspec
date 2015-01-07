# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bg_s3uploadable/version'

Gem::Specification.new do |spec|
  spec.name          = "bg_s3uploadable"
  spec.version       = BgS3uploadable::VERSION
  spec.authors       = ["Keitaroh Kobayashi"]
  spec.email         = ["keita@kkob.us"]
  spec.summary       = %q{Extension for direct and background S3 uploading to Paperclip}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/keichan34/bg_s3uploadable"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rails", "~> 4.2"
  spec.add_runtime_dependency "aws-sdk", "< 2.0"
  spec.add_runtime_dependency "jquery.fileupload-rails", "~> 1.11"
  spec.add_runtime_dependency "paperclip", ">= 4.2"
  spec.add_runtime_dependency "coffee-rails", "~> 4.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
end
