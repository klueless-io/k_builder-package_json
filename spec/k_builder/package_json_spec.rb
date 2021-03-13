# frozen_string_literal: true

RSpec.describe KBuilder::PackageJson do
  it "has a version number" do
    expect(KBuilder::PackageJson::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
