# frozen_string_literal: true

RSpec.describe KBuilder::PackageJson do
  it 'has a version number' do
    expect(KBuilder::PackageJson::VERSION).not_to be nil
  end

  it 'has a standard error' do
    expect { raise KBuilder::PackageJson::Error, 'some message' }
      .to raise_error('some message')
  end
end

if ENV['KLUE_DEBUG']&.to_s&.downcase == 'true'
  namespace = 'KBuilder::PackageJson::Version'
  file_path = $LOADED_FEATURES.find { |f| f.include?('k_builder/package_json/version') }
  version   = KBuilder::PackageJson::VERSION.ljust(9)
  puts "#{namespace.ljust(35)} : #{version.ljust(9)} : #{file_path}"
end
