# frozen_string_literal: true

RSpec.describe KBuilder::PackageJson::Configuration do
  let(:builder_module) { KBuilder }
  let(:cfg) { ->(config) {} }
  let(:instance) { builder_module.configuration }

  let(:custom_target_folder) { '~/my-target-folder' }
  let(:custom_template_folder) { '~/my-template-folder' }
  let(:custom_global_template_folder) { '~/my-template-folder-global' }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  context 'general configuration - inherited from KBuilder::Configuration' do
    let(:cfg) do
      lambda { |config|
        config.template_folder = custom_template_folder
        config.template_folder = custom_template_folder
        config.global_template_folder = custom_global_template_folder
      }
    end

    describe 'attributes' do
      subject { instance }

      it do
        is_expected
          .to have_attributes(
            target_folder: instance.target_folder,
            template_folder: instance.template_folder,
            global_template_folder: instance.global_template_folder
          )
      end
    end
  end

  context 'add package_json configuration' do
    let(:cfg) do
      lambda { |config|
        config.template_folder = custom_template_folder
        config.template_folder = custom_template_folder
        config.global_template_folder = custom_global_template_folder
        config.package_json.default_package_groups
      }
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
