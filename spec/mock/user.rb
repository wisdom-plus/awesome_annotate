# frozen_string_literal: true

class User < ActiveRecord::Base
  def self.column_names
    %w[id name email created_at updated_at]
  end
end
