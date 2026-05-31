# frozen_string_literal: true

require 'active_record'
require 'thor'
require_relative 'annotation_block'
require_relative 'error'
require_relative 'rails_environment'
require_relative 'schema_annotation'

module AwesomeAnnotate
  class Model < Thor
    include AnnotationBlock
    include Thor::Actions
    include RailsEnvironment
    include SchemaAnnotation

    def initialize(params = {})
      super()
      @env_file_path = Pathname.new(params[:env_file_path] || 'config/environment.rb')
      @model_dir = Pathname.new(params[:model_dir] || 'app/models')
      @annotation_position = params[:annotation_position] || 'top'
      @exclude_model_files = params[:exclude_model_files] || []
      @include_indexes = params.fetch(:include_indexes, true)
      @exclude_columns = params[:exclude_columns] || []
      @include_column_defaults = params.fetch(:include_column_defaults, true)
    end

    desc 'model [model name]', 'annotate your model'
    def annotate(model_name)
      raise 'Rails application path is required' unless @env_file_path.exist?

      load_rails_environment
      annotate_loaded_model(model_name)
    end

    desc 'models [model names]', 'annotate all models or specified models'
    def annotate_all(model_names = [])
      raise 'Rails application path is required' unless @env_file_path.exist?

      load_rails_environment

      if model_names.empty?
        discover_model_names.each { |model_name| annotate_discovered_model(model_name) }
      else
        model_names.each { |model_name| annotate_loaded_model(model_name) }
      end
    end

    desc 'remove [model name]', 'remove annotation from your model'
    def remove(model_name)
      file_path = model_file_path(model_name)

      remove_model_annotation(file_path)
    end

    desc 'remove_all [model names]', 'remove annotations from all models or specified models'
    def remove_all(model_names = [])
      if model_names.empty?
        discovered_model_file_paths.each { |file_path| remove_model_annotation(file_path, report_missing: false) }
      else
        model_names.each { |model_name| remove(model_name) }
      end
    end

    private

    def annotate_loaded_model(model_name, report_missing: true)
      klass = klass_name(model_name, report_missing: report_missing)

      return say 'This model does not inherit activerecord' unless klass < ActiveRecord::Base

      file_path = model_file_path(model_name)

      insert_file_before_class(file_path, schema_annotation(klass))

      say "annotate #{model_name.pluralize} table columns in #{file_path}"
    end

    def discover_model_names
      discovered_model_file_paths.map { |file_path| model_name_from_file_path(file_path) }
    end

    def discovered_model_file_paths = Dir.glob(@model_dir.join('**/*.rb')).reject { |path| excluded_model_file?(path) }

    def model_name_from_file_path(file_path)
      Pathname.new(file_path).relative_path_from(@model_dir).sub_ext('').to_s
    end

    def excluded_model_file?(file_path)
      relative_path = Pathname.new(file_path).relative_path_from(@model_dir).to_s

      relative_path == 'application_record.rb' || relative_path.start_with?('concerns/') ||
        excluded_by_config?(relative_path)
    end

    def excluded_by_config?(relative_path)
      @exclude_model_files.any? { |pattern| File.fnmatch?(pattern, relative_path, File::FNM_PATHNAME) }
    end

    def annotate_discovered_model(model_name)
      annotate_loaded_model(model_name, report_missing: false)
    rescue AwesomeAnnotate::NotFoundError
      nil
    end

    def remove_model_annotation(file_path, report_missing: true)
      if remove_annotation(file_path: file_path, marker: 'columns')
        say "remove model annotation in #{file_path}"
      elsif report_missing
        say "no model annotation in #{file_path}"
      end
    end

    def insert_file_before_class(file_path, message)
      replace_or_insert_annotation(file_path: file_path, marker: 'columns', content: message,
                                   before: /^class\s+\w+\s+<\s+\w+/, position: @annotation_position)
    end

    def model_file_path(model_name)
      file_path = "#{@model_dir}/#{model_name}.rb"

      unless File.exist?(file_path)
        say 'Model file not found'
        raise AwesomeAnnotate::NotFoundError
      end

      file_path
    end

    def klass_name(model_name, report_missing: true)
      name = model_name.singularize.camelize
      Object.const_get(name)
    rescue NameError
      say 'Model not found' if report_missing
      raise AwesomeAnnotate::NotFoundError
    end

    def self.source_root = Dir.pwd

    private_class_method :source_root
  end
end
