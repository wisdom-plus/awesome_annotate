# frozen_string_literal: true

require 'active_record'
require 'thor'
require_relative 'annotation_block'
require_relative 'rails_environment'

module AwesomeAnnotate
  class Route < Thor
    include AnnotationBlock
    include Thor::Actions
    include RailsEnvironment

    def initialize(params = {})
      super()
      @env_file_path = Pathname.new(params[:env_file_path] || 'config/environment.rb')
      @route_file_path = Pathname.new(params[:route_file_path] || 'config/routes.rb')
      @annotation_position = params[:annotation_position] || 'top'
      @exclude_routes = params[:exclude_routes] || []
    end

    desc 'annotate all routes', 'annotate your routes'
    def annotate
      raise 'Rails application path is required' unless @env_file_path.exist?

      load_rails_environment

      inspector = ActionDispatch::Routing::RoutesInspector.new(Rails.application.routes.routes)
      formatter = ActionDispatch::Routing::ConsoleFormatter::Sheet.new

      routes = inspector.format(formatter, {})
      route_message = parse_routes(routes)

      raise 'Route file not found' unless @route_file_path.exist?

      insert_file_before_class(@route_file_path, route_message)

      say "annotate routes in #{@route_file_path}"
    end

    desc 'remove', 'remove route annotation'
    def remove
      raise 'Route file not found' unless @route_file_path.exist?

      if remove_annotation(file_path: @route_file_path, marker: 'routes')
        say "remove route annotation in #{@route_file_path}"
      else
        say "no route annotation in #{@route_file_path}"
      end
    end

    private

    def parse_routes(routes)
      split_routes = routes.split(/\r\n|\r|\n/).reject { |route| excluded_route?(route) }
      parse_routes = split_routes.map do |route|
        "# #{route}\n"
      end
      parse_routes.push("\n")
      parse_routes.unshift("#---This is route annotate---\n#\n")
      parse_routes.join
    end

    def excluded_route?(route)
      @exclude_routes.any? { |pattern| File.fnmatch?(pattern, route.strip) }
    end

    def insert_file_before_class(file_path, message)
      replace_or_insert_annotation(
        file_path: file_path,
        marker: 'routes',
        content: message,
        before: "Rails.application.routes.draw do\n",
        position: @annotation_position
      )
    end

    def self.source_root
      Dir.pwd
    end
    private_class_method :source_root
  end
end
