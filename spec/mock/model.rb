# frozen_string_literal: true

module ActiveRecord
  class Base
    def self.column_names
      []
    end
  end
end

class Post
  def self.column_names
    %w[id name email created_at updated_at]
  end
end
