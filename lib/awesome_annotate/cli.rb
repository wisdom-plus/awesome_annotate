require 'active_record'
require 'awesome_annotate'
require 'thor'

module AwesomeAnnotate
  class CLI < Thor
    include Thor::Actions

    desc 'model [model name]', 'annotate your model'
    def model(model_name)
      rails_env_file = Pathname.new('./config/environment.rb')
      abort "Rails application path is required" unless rails_env_file.exist?

      apply rails_env_file.to_s

      name = model_name.singularize.camelize
      klass = Object.const_get(name)

      puts 'This model does not inherit activerecord' unless klass < ActiveRecord::Base

      column_names = klass.column_names
      model_dir = Pathname.new('app/models')
      file_path = "#{model_dir.to_s}/#{model_name}.rb"
      puts "Model file not found" unless File.exist?(file_path)
      insert_into_file file_path, :before => / class #{klass} \n|class #{klass} .*\n / do
        "# Columns: #{column_names.join(', ')}\n"
      end
      puts "annotate #{model_name.pluralize} table columns in #{file_path}"
    end

    private

    def self.exit_on_failure?
      true
    end

    def self.source_root
      Dir.pwd
    end
  end
end
