# frozen_string_literal: true

require 'active_record'
require 'thor'
require_relative 'annotation_block'
require_relative 'error'
require_relative 'rails_environment'

module AwesomeAnnotate
  class Model < Thor
    include AnnotationBlock
    include Thor::Actions
    include RailsEnvironment

    def initialize(params = {})
      super()
      @env_file_path = Pathname.new(params[:env_file_path] || 'config/environment.rb')
      @model_dir = Pathname.new(params[:model_dir] || 'app/models')
    end

    desc 'model [model name]', 'annotate your model'
    def annotate(model_name)
      raise 'Rails application path is required' unless @env_file_path.exist?

      load_rails_environment

      klass = klass_name(model_name)

      return say 'This model does not inherit activerecord' unless klass < ActiveRecord::Base

      file_path = model_file_path(model_name)

      insert_file_before_class(file_path, schema_annotation(klass))

      say "annotate #{model_name.pluralize} table columns in #{file_path}"
    end

    private

    def model_dir
      Pathname.new('app/models')
    end

    def insert_file_before_class(file_path, message)
      replace_or_insert_annotation(
        file_path: file_path,
        marker: 'columns',
        content: message,
        before: /^class\s+\w+\s+<\s+\w+/
      )
    end

    def schema_annotation(klass)
      columns = klass.columns
      column_name_width = columns.map { |column| column.name.length }.max || 0
      column_type_width = columns.map { |column| column_type(column).length }.max || 0

      [
        schema_header(klass),
        columns.map { |column| column_annotation(klass, column, column_name_width, column_type_width) }.join,
        "#\n"
      ].join
    end

    def schema_header(klass)
      [
        "# == Schema Information\n",
        "#\n",
        "# Table name: #{klass.table_name}\n",
        "#\n"
      ].join
    end

    def column_annotation(klass, column, column_name_width, column_type_width)
      column_name = column.name.ljust(column_name_width)
      type = column_type(column).ljust(column_type_width)
      details = column_details(klass, column)
      line = "#  #{column_name} :#{type}"

      line = "#{line} #{details.join(', ')}" if details.any?
      "#{line}\n"
    end

    def column_type(column)
      column.type.to_s
    end

    def column_details(klass, column)
      details = []
      details << 'not null' if column.null == false
      details << 'primary key' if column.name == klass.primary_key
      details << "default(#{column.default.inspect})" unless column.default.nil?
      details
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
