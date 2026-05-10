# frozen_string_literal: true

require 'awesome_annotate'
require 'awesome_annotate/model'
require 'awesome_annotate/route'
require 'awesome_annotate/version'
require 'thor'

module AwesomeAnnotate
  class Remove < Thor
    desc 'model [model_name]', 'remove annotation from a model'
    def model(model_name)
      AwesomeAnnotate::Model.new.remove(model_name)
    end

    desc 'models [model_names...]', 'remove annotations from all models or specified models'
    def models(*model_names)
      AwesomeAnnotate::Model.new.remove_all(model_names)
    end

    desc 'routes', 'remove annotation from `config/routes.rb`'
    def routes
      AwesomeAnnotate::Route.new.remove
    end

    desc 'all', 'remove annotations from all models and routes'
    def all
      AwesomeAnnotate::Model.new.remove_all
      AwesomeAnnotate::Route.new.remove
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
      AwesomeAnnotate::Model.new.annotate(model_name)
    end

    desc 'models [model_names...]', 'annotate all models or specified models'
    def models(*model_names)
      AwesomeAnnotate::Model.new.annotate_all(model_names)
    end

    map %w[routes -r] => :routes
    desc 'routes', 'Writes application route information to `config/routes.rb`.'
    def routes
      AwesomeAnnotate::Route.new.annotate
    end

    desc 'all', 'annotate all models and routes'
    def all
      AwesomeAnnotate::Model.new.annotate_all
      AwesomeAnnotate::Route.new.annotate
    end

    desc 'remove SUBCOMMAND', 'remove generated annotations'
    subcommand 'remove', Remove

    def self.exit_on_failure?
      true
    end
  end
end
