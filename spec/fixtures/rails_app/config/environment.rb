# frozen_string_literal: true

require 'active_record'
require_relative '../app/models/user'
require_relative '../app/models/article'
require_relative '../app/models/application_record'

class ActionDispatch
  class Routing
    class RoutesInspector
      def initialize(routes); end

      def format(formatter, options)
        <<~ROUTES
          Prefix Verb URI Pattern Controller#Action
          users GET /users(.:format) users#index
        ROUTES
      end
    end
  end
end

class Rails
  def self.application
    @application ||= Application.new
  end

  class Application
    def routes
      RouteCollection.new
    end
  end

  class RouteCollection
    def routes
      []
    end
  end
end
