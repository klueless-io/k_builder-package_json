# frozen_string_literal: true

module KBuilder
  module PackageJson
    # Context is a data object holding onto state that is used when building webpack configuration.
    class PackageBuilder < KBuilder::Builder
      # In memory representation of the package.json file that is being created
      attr_writer :package

      # def initialize(context)
      #   super(context)

      #   @dependency_type = :development
      # end

      # # -----------------------------------
      # # Builder Attributes
      # # -----------------------------------

      # def package
      #   return @package if defined? @package

      #   load

      #   @package
      # end

      # def package_file
      #   @package_file ||= File.join(output_path, 'package.json')
      # end

      # def dependency_option
      #   @dependency_type == :development ? '-D' : '-P'
      # end

      # # -----------------------------------
      # # Fluent Builder Methods
      # # -----------------------------------

      # def production
      #   @dependency_type = :production

      #   self
      # end

      # def development
      #   @dependency_type = :development

      #   self
      # end

      # # Set a property value in the package
      # def set(key, value)
      #   load

      #   @package[key] = value

      #   write

      #   self
      # end

      # def remove_script(key)
      #   load

      #   @package['scripts']&.delete(key)

      #   write

      #   self
      # end

      # def add_script(key, value)
      #   load

      #   @package['scripts'][key] = value

      #   write

      #   self
      # end

      # # Init an NPN package
      # #
      # # run npm init -y
      # def npm_init
      #   rc 'npm init -y'

      #   load

      #   self
      # end

      # # Space separated list of packages
      # def npm_install(packages, options: nil)
      #   npm_add_or_install(packages, parse_options(options))

      #   self
      # end
      # alias npm_i npm_install

      # def npm_add(packages, options: nil)
      #   npm_add_or_install(packages, parse_options(options, '--package-lock-only --no-package-lock'))

      #   self
      # end
      # alias npm_a npm_add

      # def npm_add_group(key, options: nil)
      #   group = get_group(key)

      #   puts "Adding #{group.description}"

      #   npm_add(group.package_names, options: options)

      #   self
      # end
      # alias npm_ag npm_add_group

      # # Add a group of NPN packages which get defined in configuration
      # def npm_install_group(key, options: nil)
      #   group = get_group(key)

      #   puts "Installing #{group.description}"

      #   npm_install(group.package_names, options: options)

      #   self
      # end

      # # Load the existing package.json into memory
      # #
      # # ToDo: Would be useful to record the update timestamp on the
      # # package so that we only load if the in memory package is not
      # # the latest.
      # #
      # # The reason this can happen, is because external tools such are
      # # npm install are updating the package.json and after this happens
      # # we need to call load, but if there is any bug in the code we may
      # # for get to load, or we may load multiple times.
      # def load
      #   raise Webpack5::Builder::Error, 'package.json does not exist' unless File.exist?(package_file)

      #   puts 'loading...'

      #   content = File.read(package_file)
      #   @package = JSON.parse(content)

      #   self
      # end

      # # -----------------------------------
      # # Helpers
      # # -----------------------------------

      # def parse_options(options = nil, required_options = nil)
      #   options = [] if options.nil?
      #   options = options.split if options.is_a?(String)
      #   options.reject(&:empty?)

      #   required_options = [] if required_options.nil?
      #   required_options = required_options.split if required_options.is_a?(String)

      #   options | required_options
      # end

      # def options_any?(options, *any_options)
      #   (options & any_options).any?
      # end

      # # Debug method to open the package file in vscode
      # # ToDo: Maybe remove
      # def vscode
      #   puts "cd #{output_path}"
      #   puts package_file
      #   rc "code #{package_file}"
      # end

      # private

      # def execute(command)
      #   puts "RUN: #{command}"
      #   rc command
      #   load
      # end

      # def get_group(key)
      #   group = context.package_groups[key]

      #   raise Webpack5::Builder::Error, "unknown package group: #{key}" if group.nil?

      #   group
      # end

      # def npm_add_or_install(packages, options)
      #   # if -P or -D is not in the options then use the current builder dependency option
      #   options.push dependency_option unless options_any?(options, '-P', '-D')
      #   packages = packages.join(' ') if packages.is_a?(Array)
      #   command = "npm install #{options.join(' ')} #{packages}"
      #   execute command
      # end

      # def write
      #   puts 'writing...'

      #   content = JSON.pretty_generate(@package)

      #   File.write(package_file, content)

      #   self
      # end
    end
  end
end
