require 'active_record'
require 'thor'

module AwesomeAnnotate
  class Route < Thor
    include Thor::Actions

    def initialize(params = {})
      super()
      @env_file_path = Pathname.new(params[:env_file_path] || 'config/environment.rb')
      @route_file_path = Pathname.new(params[:route_file_path] || 'config/routes.rb')
    end

    desc 'annotate all routes', 'annotate your routes'
    def annotate
      raise "Rails application path is required" unless @env_file_path.exist?

      apply @env_file_path.to_s

      inspector = ActionDispatch::Routing::RoutesInspector.new(Rails.application.routes.routes)
      formatter = ActionDispatch::Routing::ConsoleFormatter::Sheet.new

      routes = inspector.format(formatter, {})
      route_message = parse_routes(routes)

      raise "Route file not found" unless @route_file_path.exist?

      insert_file_before_class(@route_file_path, route_message)

      say "annotate routes in #{@route_file_path}"
    end

    private

    def parse_routes(routes)
      split_routes = routes.split(/\r\n|\r|\n/)
      parse_routes = split_routes.map do |route|
        "# #{route}\n"
      end
      parse_routes.push("\n")
      parse_routes.unshift("#---This is route annotate---\n#\n")
      parse_routes.join
    end

    def insert_file_before_class(file_path, message)
      insert_into_file file_path, :before => "Rails.application.routes.draw do\n" do
        message
      end
    end

    def self.source_root
      Dir.pwd
    end
  end
end
