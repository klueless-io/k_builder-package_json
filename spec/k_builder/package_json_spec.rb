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
