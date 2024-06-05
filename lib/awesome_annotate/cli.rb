require 'awesome_annotate'
require 'awesome_annotate/model'
require 'awesome_annotate/route'
require 'awesome_annotate/version'
require 'thor'

module AwesomeAnnotate
  class CLI < Thor
    include Thor::Actions

    map %w[--version -v] => :print_version
    desc "--version, -v", "print the version"
    def print_version
      say AwesomeAnnotate::VERSION
    end

    map %w[model -m] => :model
    desc 'model [model_name]', 'annotate your model'
    def model(model_name)
      AwesomeAnnotate::Model.new.annotate(model_name)
    end

    map %w[routes -r] => :routes
    desc 'routes', "Writes application route information to `config/routes.rb`."
    def routes
      AwesomeAnnotate::Route.new.annotate
    end

    private

    def self.exit_on_failure?
      true
    end
  end
end
