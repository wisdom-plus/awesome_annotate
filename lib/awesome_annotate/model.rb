require 'active_record'
require 'thor'
require_relative 'error'

module AwesomeAnnotate
  class Model < Thor
    include Thor::Actions

    def initialize(params = {})
      super()
      @env_file_path = Pathname.new(params[:env_file_path] || 'config/environment.rb')
      @model_dir = Pathname.new(params[:model_dir] || 'app/models')
    end

    desc 'model [model name]', 'annotate your model'
    def annotate(model_name)
      raise "Rails application path is required" unless @env_file_path.exist?

      apply @env_file_path.to_s

      klass = klass_name(model_name)

      return say 'This model does not inherit activerecord' unless klass < ActiveRecord::Base

      column_names = column_names(klass)
      file_path = model_file_path(model_name)

      insert_file_before_class(file_path, klass, "# Columns: #{column_names.join(', ')}\n")

      say "annotate #{model_name.pluralize} table columns in #{file_path}"
    end

    private

    def model_dir
      Pathname.new('app/models')
    end

    def insert_file_before_class(file_path, klass, message)
      insert_into_file file_path, :before => /^class\s+\w+\s+<\s+\w+/ do
        message
      end
    end

    def column_names(klass)
      klass.column_names
    end

    def model_file_path(model_name)
      file_path = "#{@model_dir}/#{model_name}.rb"

      unless File.exist?(file_path)
        say "Model file not found"
        raise NotFoundError
      end

      return file_path
    end

    def klass_name(model_name)
      name = model_name.singularize.camelize
      return Object.const_get(name)

    rescue NameError
      say "Model not found"
      raise NotFoundError
    end

    def self.source_root
      Dir.pwd
    end
  end
end
