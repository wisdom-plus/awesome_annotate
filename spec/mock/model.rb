class ActiveRecord::Base
  def self.column_names
    []
  end
end

class Post
  def self.column_names
    ['id', 'name', 'email', 'created_at', 'updated_at']
  end
end
