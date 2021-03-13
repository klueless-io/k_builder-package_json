# frozen_string_literal: true

# Warning: I am not using mocks and so there is a known test anti
#          I am aware that this is an Anti Pattern in unit testing
#          but I am sticking with this pattern for now as it saves
#          me a lot of time in writing tests.
# Future:  May want to remove this Anti Pattern
RSpec.describe KBuilder::PackageJson::PackageBuilder do
  let(:builder_module) { KBuilder }
  let(:cfg) { ->(config) {} }
  let(:builder) { described_class.new }
end
