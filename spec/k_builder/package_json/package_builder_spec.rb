# frozen_string_literal: true

RSpec.describe KBuilder::PackageJson::PackageBuilder do
  let(:builder_module) { KBuilder }
  let(:builder) { described_class.new }

  let(:samples_folder) { File.join(Dir.getwd, 'spec', 'samples') }
  let(:target_folder) { samples_folder }
  let(:app_template_folder) { File.join(Dir.getwd, 'spec', 'samples', 'app-template') }
  let(:global_template_folder) { File.join(Dir.getwd, 'spec', 'samples', 'global-template') }

  let(:cfg) do
    lambda { |config|
      config.target_folder = target_folder
      config.template_folder = app_template_folder
      config.global_template_folder = global_template_folder
    }
  end

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  describe '#initialize' do
    subject { builder }

    context 'with default configuration' do
      it { is_expected.not_to be_nil }
    end

    describe '.target_folder' do
      subject { builder.target_folder }
      it { is_expected.to eq(target_folder) }
    end

    describe '.template_folder' do
      subject { builder.template_folder }
      it { is_expected.to eq(app_template_folder) }
    end

    describe '.global_template_folder' do
      subject { builder.global_template_folder }
      it { is_expected.to eq(global_template_folder) }
    end

    describe '.package_file' do
      subject { builder.package_file }
      it { is_expected.not_to be_empty }
      it { is_expected.to eq(File.join(builder.target_folder, 'package.json')) }
    end

    context '.dependency_type' do
      subject { builder.dependency_type }
      it { is_expected.to eq(:development) }
    end

    describe '.package' do
      subject { builder.package }

      it { expect(-> { subject }).to raise_error KBuilder::PackageJson::Error, 'package.json does not exist' }
    end
  end

  context 'set context for production/development' do
    context 'when production' do
      before { builder.production }

      context '.dependency_type' do
        subject { builder.dependency_type }
        it { is_expected.to eq(:production) }
      end
      context '.dependency_option' do
        subject { builder.dependency_option }
        it { is_expected.to eq('-P') }
      end
    end

    context 'when development' do
      before { builder.development }

      context '.dependency_type' do
        subject { builder.dependency_type }
        it { is_expected.to eq(:development) }
      end
      context '.dependency_option' do
        subject { builder.dependency_option }
        it { is_expected.to eq('-D') }
      end
    end
  end

  describe '#npm_init' do
    include_context :use_temp_folder

    let(:target_folder) { @temp_folder }

    before :each do
      builder.npm_init
    end

    # fit { puts JSON.pretty_generate(builder.hash) }
    describe '#package_file' do
      subject { builder.package_file }

      it { is_expected.to eq(File.join(target_folder, 'package.json')) }
    end

    describe '#package' do
      subject { builder.package }

      it { is_expected.to include('name' => start_with('rspec-')) }
    end

    context 'set custom package property' do
      subject { builder.set('description', 'some description').package }

      it { is_expected.to include('description' => 'some description') }
    end

    context 'working with scripts' do
      subject { builder.package['scripts'] }

      context 'has default script' do
        it { is_expected.to have_key('test') }
      end

      context 'remove script' do
        subject { builder.remove_script('test').package['scripts'] }

        it { is_expected.not_to have_key('test') }
      end

      context 'add script' do
        subject { builder.add_script('custom', 'do something').package['scripts'] }

        it do
          is_expected
            .to  have_key('custom')
            .and include('custom' => a_value)
        end
      end
    end
  end
end
