# frozen_string_literal: true

class Article < ActiveRecord::Base
  Column = Struct.new(:name, :type, :null, :default, keyword_init: true) unless const_defined?(:Column, false)

  def self.columns
    [
      Column.new(name: 'id', type: :integer, null: false),
      Column.new(name: 'title', type: :string, null: false),
      Column.new(name: 'published', type: :boolean, null: false, default: false)
    ]
  end

  def self.primary_key
    'id'
  end

  def self.table_name
    'articles'
  end

  def self.connection
    Connection.new
  end

  class Connection
    def indexes(_table_name)
      []
    end
  end
end
