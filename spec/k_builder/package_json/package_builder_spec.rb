# frozen_string_literal: true

RSpec.describe KBuilder::PackageJson::PackageBuilder do
  let(:builder_module) { KBuilder }
  let(:builder) { described_class.new }

  let(:samples_folder) { File.join(Dir.getwd, 'spec', 'samples') }
  let(:target_folder) { samples_folder }
  let(:app_template_folder) { File.join(samples_folder, 'app-template') }
  let(:global_template_folder) { File.join(samples_folder, 'global-template') }

  let(:cfg) do
    lambda { |config|
      config.target_folders.add(:package, target_folder)

      config.template_folders.add(:global , global_template_folder)
      config.template_folders.add(:app , app_template_folder)
    }
  end

  let(:yallist) { 'yallist' }
  let(:node_target_yallist) { File.join(builder.target_folder, 'node_modules', 'yallist') }
  let(:boolbase) { 'boolbase' }
  let(:node_target_boolbase) { File.join(builder.target_folder, 'node_modules', 'boolbase') }
  let(:multiple_packages) { [yallist, boolbase] }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  describe '#initialize' do
    subject { builder }

    context 'with default configuration' do
      fit { is_expected.not_to be_nil }
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

  describe '#parse_options' do
    subject { builder.parse_options(options).join(' ') }
    let(:options) { nil }

    context 'when nil' do
      it { is_expected.to be_empty }
    end

    context 'when empty string' do
      let(:options) { '' }
      it { is_expected.to be_empty }
    end

    context 'when multiple options' do
      let(:options) { '-a -B --c' }
      it { is_expected.to eq('-a -B --c') }
    end

    context 'when multiple options wit extra spacing' do
      let(:options) { '-abc     -xyz' }
      it { is_expected.to eq('-abc -xyz') }
    end

    context 'with required_options' do
      subject { builder.parse_options(options, required_options).join(' ') }

      let(:options) { '-a     -b' }
      let(:required_options) { nil }

      context 'when nil' do
        it { is_expected.to eq('-a -b') }
      end

      context 'when empty string' do
        let(:required_options) { '' }
        it { is_expected.to eq('-a -b') }
      end

      context 'when add required option' do
        let(:required_options) { '-req-option' }
        it { is_expected.to eq('-a -b -req-option') }
      end

      context 'when add existing and required options' do
        let(:required_options) { '-req1   -b  -req2 -a' }
        it { is_expected.to eq('-a -b -req1 -req2') }
      end
    end
  end

  describe '#npm_init' do
    include_context :use_temp_folder

    let(:target_folder) { @temp_folder }

    before :each do
      builder.npm_init
    end

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

  describe '#npm_install' do
    include_context :use_temp_folder

    let(:target_folder) { @temp_folder }

    context 'when options are configured via builder' do
      subject { builder.package }

      before :each do
        builder.npm_init
               .production
               .npm_install(boolbase)
               .development
               .npm_install(yallist)
      end

      it do
        expect(Dir.exist?(node_target_yallist)).to be_truthy
        expect(Dir.exist?(node_target_boolbase)).to be_truthy

        is_expected
          .to  have_key('dependencies')
          .and include('dependencies' => { 'boolbase' => a_value })
          .and have_key('devDependencies')
          .and include('devDependencies' => { 'yallist' => a_value })
      end
    end

    context 'when two packages are supplied manually' do
      subject { builder.package }
      before :each do
        builder.npm_init
               .npm_install(multiple_packages, options: options)
      end

      context 'development' do
        let(:options) { '-D' }

        it do
          expect(Dir.exist?(node_target_yallist)).to be_truthy
          expect(Dir.exist?(node_target_boolbase)).to be_truthy

          is_expected
            .to  have_key('devDependencies')
            .and include('devDependencies' => { 'yallist' => a_value, 'boolbase' => a_value })
        end
      end
    end

    context 'when options are supplied manually' do
      subject { builder.package }

      before :each do
        builder.npm_init
               .npm_install(yallist, options: options)
      end

      context 'install dependency' do
        context 'development' do
          let(:options) { '-D' }

          it do
            expect(Dir.exist?(node_target_yallist)).to be_truthy

            is_expected.to have_key('devDependencies')
              .and include('devDependencies' => { 'yallist' => a_value })
          end
        end

        context 'production' do
          let(:options) { '-P' }

          it do
            expect(Dir.exist?(node_target_yallist)).to be_truthy

            is_expected.to have_key('dependencies')
              .and include('dependencies' => { 'yallist' => a_value })
          end
        end
      end
    end
  end

  describe '#npm_add' do
    include_context :use_temp_folder

    let(:target_folder) { @temp_folder }

    # adds dependency, but does not install
    subject { builder.package }

    context 'when options are configured via builder' do
      before :each do
        builder.npm_init
               .production
               .npm_add(boolbase)
               .development
               .npm_add(yallist)
      end

      it do
        expect(Dir.exist?(node_target_yallist)).to be_falsey
        expect(Dir.exist?(node_target_boolbase)).to be_falsey

        is_expected
          .to  have_key('dependencies')
          .and include('dependencies' => { 'boolbase' => a_value })
          .and have_key('devDependencies')
          .and include('devDependencies' => { 'yallist' => a_value })
      end
    end

    context 'when options are supplied manually' do
      before :each do
        builder.npm_init
               .npm_add(yallist, options: options)
      end

      context 'development' do
        let(:options) { '-D' }

        it do
          expect(Dir.exist?(node_target_yallist)).to be_falsey

          is_expected.to have_key('devDependencies')
            .and include('devDependencies' => { 'yallist' => a_value })
        end
      end

      context 'production' do
        let(:options) { '-P' }

        it do
          expect(Dir.exist?(node_target_yallist)).to be_falsey

          is_expected.to have_key('dependencies')
            .and include('dependencies' => { 'yallist' => a_value })
        end
      end
    end
  end

  describe '#npm_add_group' do
    include_context :use_temp_folder

    let(:target_folder) { @temp_folder }

    # adds dependency, but does not install
    subject { builder.package }

    let(:cfg) do
      lambda { |config|
        config.target_folder = target_folder
        config.package_json.default_package_groups
        config.package_json.set_package_group('xmen', 'Sample Packages', multiple_packages)
      }
    end

    context 'when options are configured via builder' do
      before :each do
        builder.npm_init
               .production
               .npm_add_group('xmen')
      end

      it do
        expect(Dir.exist?(node_target_yallist)).to be_falsey
        expect(Dir.exist?(node_target_boolbase)).to be_falsey

        is_expected
          .to  have_key('dependencies')
          .and include('dependencies' => { 'boolbase' => a_value, 'yallist' => a_value })
      end
    end

    context 'when options are supplied manually' do
      before :each do
        builder.npm_init
               .npm_add_group('xmen', options: options)
      end

      context 'development' do
        let(:options) { '-D' }

        it do
          expect(Dir.exist?(node_target_yallist)).to be_falsey
          expect(Dir.exist?(node_target_yallist)).to be_falsey

          is_expected
            .to have_key('devDependencies')
            .and include('devDependencies' => { 'yallist' => a_value, 'boolbase' => a_value })
        end
      end
    end
  end

  describe '#npm_install_group' do
    include_context :use_temp_folder

    let(:target_folder) { @temp_folder }

    subject { builder.package }

    let(:cfg) do
      lambda { |config|
        config.target_folder = target_folder
        config.package_json.default_package_groups
        config.package_json.set_package_group('xmen', 'Sample Packages', multiple_packages)
      }
    end

    context 'when options are configured via builder' do
      before :each do
        builder.npm_init
               .production
               .npm_install_group('xmen')
      end

      it do
        expect(Dir.exist?(node_target_yallist)).to be_truthy
        expect(Dir.exist?(node_target_boolbase)).to be_truthy

        is_expected
          .to  have_key('dependencies')
          .and include('dependencies' => { 'boolbase' => a_value, 'yallist' => a_value })
      end
    end

    context 'when options are supplied manually' do
      before :each do
        builder.npm_init
               .npm_install_group('xmen', options: options)
      end

      context 'development' do
        let(:options) { '-D' }

        it do
          expect(Dir.exist?(node_target_yallist)).to be_truthy
          expect(Dir.exist?(node_target_yallist)).to be_truthy

          is_expected
            .to have_key('devDependencies')
            .and include('devDependencies' => { 'yallist' => a_value, 'boolbase' => a_value })
        end
      end
    end
  end
end
