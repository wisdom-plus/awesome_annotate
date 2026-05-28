# frozen_string_literal: true

module AwesomeAnnotate
  module SchemaAnnotation
    private

    def schema_annotation(klass)
      columns = klass.columns
      column_name_width = columns.map { |column| column.name.length }.max || 0
      column_type_width = columns.map { |column| column_type(column).length }.max || 0

      [
        schema_header(klass),
        columns.map { |column| column_annotation(klass, column, column_name_width, column_type_width) }.join,
        index_annotations(klass),
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

    def index_annotations(klass)
      indexes = klass.connection.indexes(klass.table_name)
      return '' if indexes.empty?

      index_column_width = indexes.map { |index| index_columns(index).length }.max || 0

      [
        "#\n",
        "# Indexes\n",
        "#\n",
        indexes.map { |index| index_annotation(index, index_column_width) }.join
      ].join
    end

    def index_annotation(index, index_column_width)
      columns = index_columns(index).ljust(index_column_width)
      details = index_details(index)

      "#  #{columns}  #{details.join(', ')}\n"
    end

    def index_columns(index)
      "(#{index.columns.join(',')})"
    end

    def index_details(index)
      details = []
      details << 'UNIQUE' if index.unique
      details << index.name
      details
    end
  end
end
