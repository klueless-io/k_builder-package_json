# frozen_string_literal: true

require 'k_builder'
require 'k_builder/package_json/version'
require 'k_builder/package_json/package_builder'

module KBuilder
  module PackageJson
    # raise KBuilder::PackageJson::Error, 'Sample message'
    class Error < StandardError; end
  end
end
