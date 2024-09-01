class User < ActiveRecord::Base
  def self.column_names
    ['id', 'name', 'email', 'created_at', 'updated_at']
  end
end
