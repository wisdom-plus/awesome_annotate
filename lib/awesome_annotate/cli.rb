# frozen_string_literal: true

require 'awesome_annotate'
require 'awesome_annotate/configuration'
require 'awesome_annotate/model'
require 'awesome_annotate/route'
require 'awesome_annotate/version'
require 'thor'

module AwesomeAnnotate
  class Remove < Thor
    desc 'model [model_name]', 'remove annotation from a model'
    def model(model_name)
      model_annotator.remove(model_name)
    end

    desc 'models [model_names...]', 'remove annotations from all models or specified models'
    def models(*model_names)
      model_annotator.remove_all(model_names)
    end

    desc 'routes', 'remove annotation from `config/routes.rb`'
    def routes
      route_annotator.remove
    end

    desc 'all', 'remove annotations from all models and routes'
    def all
      model_annotator.remove_all
      route_annotator.remove
    end

    private

    def model_annotator
      AwesomeAnnotate::Model.new(configuration.options)
    end

    def route_annotator
      AwesomeAnnotate::Route.new(configuration.options)
    end

    def configuration
      AwesomeAnnotate::Configuration.load
    end
  end

  class CLI < Thor
    include Thor::Actions

    map %w[--version -v] => :print_version
    desc '--version, -v', 'print the version'
    def print_version
      say AwesomeAnnotate::VERSION
    end

    map %w[model -m] => :model
    desc 'model [model_name]', 'annotate your model'
    def model(model_name)
      model_annotator.annotate(model_name)
    end

    desc 'models [model_names...]', 'annotate all models or specified models'
    def models(*model_names)
      model_annotator.annotate_all(model_names)
    end

    map %w[routes -r] => :routes
    desc 'routes', 'Writes application route information to `config/routes.rb`.'
    def routes
      route_annotator.annotate
    end

    desc 'all', 'annotate all models and routes'
    def all
      model_annotator.annotate_all
      route_annotator.annotate
    end

    desc 'init', "create #{AwesomeAnnotate::Configuration::DEFAULT_PATH}"
    def init
      path = AwesomeAnnotate::Configuration::DEFAULT_PATH
      if File.exist?(path)
        say "Config file already exists: #{path}"
      else
        AwesomeAnnotate::Configuration.create(path)
        say "create #{path}"
      end
    end

    desc 'remove SUBCOMMAND', 'remove generated annotations'
    subcommand 'remove', Remove

    def self.exit_on_failure?
      true
    end

    private

    def model_annotator
      AwesomeAnnotate::Model.new(configuration.options)
    end

    def route_annotator
      AwesomeAnnotate::Route.new(configuration.options)
    end

    def configuration
      AwesomeAnnotate::Configuration.load
    end
  end
end
