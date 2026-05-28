# frozen_string_literal: true

class User < ActiveRecord::Base
  Column = Struct.new(:name, :type, :null, :default, keyword_init: true) unless const_defined?(:Column, false)
  Index = Struct.new(:columns, :unique, :name, keyword_init: true) unless const_defined?(:Index, false)

  def self.columns
    [
      Column.new(name: 'id', type: :integer, null: false),
      Column.new(name: 'name', type: :string, null: true),
      Column.new(name: 'email', type: :string, null: false, default: ''),
      Column.new(name: 'created_at', type: :datetime, null: false),
      Column.new(name: 'updated_at', type: :datetime, null: false)
    ]
  end

  def self.primary_key
    'id'
  end

  def self.table_name
    'users'
  end

  def self.connection
    Connection.new
  end

  class Connection
    def indexes(_table_name)
      [
        Index.new(columns: ['email'], unique: true, name: 'index_users_on_email'),
        Index.new(columns: %w[name email], unique: false, name: 'index_users_on_name_and_email')
      ]
    end
  end
end
