# frozen_string_literal: true

module AwesomeAnnotate
  module RailsEnvironment
    private

    def load_rails_environment
      require @env_file_path.expand_path.to_s
    end
  end
end
