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

    private

    def annotate_loaded_model(model_name)
      klass = klass_name(model_name)

      return say 'This model does not inherit activerecord' unless klass < ActiveRecord::Base

      file_path = model_file_path(model_name)

      insert_file_before_class(file_path, schema_annotation(klass))

      say "annotate #{model_name.pluralize} table columns in #{file_path}"
    end

    def model_dir
      Pathname.new('app/models')
    end

    def discover_model_names
      Dir.glob(@model_dir.join('**/*.rb')).filter_map do |file_path|
        next if excluded_model_file?(file_path)

        Pathname.new(file_path).relative_path_from(@model_dir).sub_ext('').to_s
      end
    end

    def excluded_model_file?(file_path)
      relative_path = Pathname.new(file_path).relative_path_from(@model_dir).to_s

      relative_path == 'application_record.rb' || relative_path.start_with?('concerns/')
    end

    def annotate_discovered_model(model_name)
      annotate_loaded_model(model_name)
    rescue AwesomeAnnotate::NotFoundError
      nil
    end

    def insert_file_before_class(file_path, message)
      replace_or_insert_annotation(
        file_path: file_path,
        marker: 'columns',
        content: message,
        before: /^class\s+\w+\s+<\s+\w+/
      )
    end

    def model_file_path(model_name)
      file_path = "#{@model_dir}/#{model_name}.rb"

      unless File.exist?(file_path)
        say 'Model file not found'
        raise AwesomeAnnotate::NotFoundError
      end

      file_path
    end

    def klass_name(model_name)
      name = model_name.singularize.camelize
      Object.const_get(name)
    rescue NameError
      say 'Model not found'
      raise AwesomeAnnotate::NotFoundError
    end

    def self.source_root
      Dir.pwd
    end
    private_class_method :source_root
  end
end
