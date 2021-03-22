# frozen_string_literal: true

RSpec.describe KBuilder::PackageJson::Configuration do
  let(:builder_module) { KBuilder }
  let(:cfg) { ->(config) {} }
  let(:instance) { builder_module.configuration }

  let(:custom_target_folder) { '~/my-target-folder' }
  let(:expected_target_folder) { File.expand_path(custom_target_folder) }

  let(:custom_template_folder) { '~/my-template-folder' }
  let(:custom_global_template_folder) { '~/my-template-folder-global' }

  let(:expected_template_folder) { File.expand_path(custom_template_folder) }
  let(:expected_global_template_folder) { File.expand_path(custom_global_template_folder) }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  shared_context 'general configuration' do
    let(:cfg) do
      lambda { |config|
        config.target_folders.add(:app , custom_target_folder)

        config.template_folders.add(:domain , custom_global_template_folder)
        config.template_folders.add(:app    , custom_template_folder)
      }
    end
  end

  # These baselines are inherited from KBuilder::Configuration
  describe '.target_folders' do
    subject { instance.target_folders.folders }

    context 'when not configured' do
      it { is_expected.to be_empty }
    end

    context 'when configured' do
      include_context 'general configuration'

      it do
        is_expected
          .to  include(app: expected_target_folder)
      end
    end
  end

  # These baselines are inherited from KBuilder::Configuration
  describe '.template_folders' do
    subject { instance.template_folders.folders }

    context 'when not configured' do
      it { is_expected.to be_empty }
    end

    context 'when configured' do
      include_context 'general configuration'

      it do
        is_expected
          .to  include(app: expected_template_folder)
      end
    end
  end

  context 'add package_json configuration' do
    include_context 'general configuration'

    before do
      instance.package_json.default_package_groups
    end

    it { is_expected.to respond_to(:package_json) }

    describe '.package_json' do
      subject { instance.package_json }

      it { is_expected.to respond_to(:package_groups) }

      context '.package_groups' do
        subject { instance.package_json.package_groups }

        it do
          is_expected
            .to  have_key('webpack')
            .and have_key('swc')
            .and have_key('babel')
            .and have_key('typescript')
        end

        context ".package_group['webpack']" do
          subject { instance.package_json.package_groups['webpack'] }

          it do
            is_expected
              .to have_attributes(key: 'webpack',
                                  description: 'Webpack V5',
                                  package_names: %w[webpack webpack-cli webpack-dev-server])
          end
        end
      end
    end
  end
end
