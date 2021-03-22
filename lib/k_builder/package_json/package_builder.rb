# frozen_string_literal: true

module KBuilder
  module PackageJson
    # Configuration currently comes from KBuilder and stores template folders and target folders if configured
    class PackageBuilder < KBuilder::BaseBuilder
      # In memory representation of the package.json file that is being created

      attr_writer :package

      attr_reader :package_file
      attr_accessor :dependency_type

      def initialize(configuration = nil)
        super(configuration)

        set_package_file('package.json')
        set_dependency_type(:development)
      end

      # ----------------------------------------------------------------------
      # Fluent interface
      # ----------------------------------------------------------------------

      # Change context to production, new dependencies will be for production
      def production
        set_dependency_type(:production)

        self
      end

      # Change context to development, new dependencies will be for development
      def development
        set_dependency_type(:development)

        self
      end

      # Init an NPN package
      #
      # run npm init -y
      #
      # Note: npm init does not support --silent operation
      def npm_init
        rc 'npm init -y'

        load

        self
      end

      # Space separated list of packages
      def npm_install(packages, options: nil)
        npm_add_or_install(packages, parse_options(options))

        self
      end
      alias npm_i npm_install

      def npm_add(packages, options: nil)
        npm_add_or_install(packages, parse_options(options, '--package-lock-only --no-package-lock'))

        self
      end
      alias npm_a npm_add

      def npm_add_group(key, options: nil)
        group = get_group(key)

        puts "Adding #{group.description}"

        npm_add(group.package_names, options: options)

        self
      end
      alias npm_ag npm_add_group

      # Add a group of NPN packages which get defined in configuration
      def npm_install_group(key, options: nil)
        group = get_group(key)

        puts "Installing #{group.description}"

        npm_install(group.package_names, options: options)

        self
      end

      # Load the existing package.json into memory
      #
      # ToDo: Would be useful to record the update timestamp on the package
      # so that we only load if the in memory package is not the latest.
      #
      # The reason this can happen, is because external tools such are
      # npm install are updating the package.json and after this happens
      # we need to call load, but if there is any bug in the code we may
      # for get to load, or we may load multiple times.
      def load
        raise KBuilder::PackageJson::Error, 'package.json does not exist' unless File.exist?(package_file)

        puts 'loading...'

        content = File.read(package_file)
        @package = JSON.parse(content)

        self
      end

      # Write the package.json file
      def write
        puts 'writing...'

        content = JSON.pretty_generate(@package)

        File.write(package_file, content)

        self
      end

      # Remove a script reference by key
      def remove_script(key)
        load

        @package['scripts']&.delete(key)

        write

        self
      end

      # Add a script with key and value (command line to run)
      def add_script(key, value)
        load

        @package['scripts'][key] = value

        write

        self
      end

      # ----------------------------------------------------------------------
      # Attributes: Think getter/setter
      #
      # The following getter/setters can be referenced both inside and outside
      # of the fluent builder fluent API. They do not implement the fluent
      # interface unless prefixed by set_.
      #
      # set_: Only setters with the prefix _set are considered fluent.
      # ----------------------------------------------------------------------

      # Package
      # ----------------------------------------------------------------------

      # Load the package.json into a memory as object
      def package
        return @package if defined? @package

        load

        @package
      end

      # Package.set
      # ----------------------------------------------------------------------

      # Set a property value in the package
      def set(key, value)
        load

        @package[key] = value

        write

        self
      end

      # Dependency option
      # ----------------------------------------------------------------------

      # Getter for dependency option
      def dependency_option
        dependency_type == :development ? '-D' : '-P'
      end

      # Dependency type
      # ----------------------------------------------------------------------

      # Fluent setter for target folder
      def set_dependency_type(value)
        self.dependency_type = value

        self
      end

      # Target folder
      # ----------------------------------------------------------------------

      # Fluent setter for target folder
      def set_package_file(value)
        self.package_file = value

        self
      end

      # Setter for target folder
      def package_file=(_value)
        @package_file = File.join(target_folder, 'package.json')
      end

      # # Getter for target folder
      # def package_file
      #   hash['package_file']
      # end

      # -----------------------------------
      # Helpers
      # -----------------------------------

      def parse_options(options = nil, required_options = nil)
        options = [] if options.nil?
        options = options.split if options.is_a?(String)
        options.reject(&:empty?)

        required_options = [] if required_options.nil?
        required_options = required_options.split if required_options.is_a?(String)

        options | required_options
      end

      def options_any?(options, *any_options)
        (options & any_options).any?
      end

      def execute(command)
        puts "RUN: #{command}"
        rc command
        load
      end

      def npm_add_or_install(packages, options)
        # if -P or -D is not in the options then use the current builder dependency option
        options.push dependency_option unless options_any?(options, '-P', '-D')
        packages = packages.join(' ') if packages.is_a?(Array)
        command = "npm install #{options.join(' ')} #{packages}"
        execute command
      end

      # # Debug method to open the package file in vscode
      # # ToDo: Maybe remove
      # def vscode
      #   puts "cd #{output_path}"
      #   puts package_file
      #   rc "code #{package_file}"
      # end

      # private

      # This is all wrong, but useful for now
      def context
        @context ||= KBuilder.data.to_struct(configuration)
      end

      def get_group(key)
        group = context.package_json.package_groups[key]

        raise KBuilder::PackageJson::Error, "unknown package group: #{key}" if group.nil?

        group
      end
    end
  end
end
