require 'awesome_annotate'
require 'thor'
require 'active_record'

module AwesomeAnnotate
  class CLI < Thor
    desc "annotate", "annotate your code"
    def annotate
      puts "annotate your code"
      return 'annotate your code'
      # AwesomeAnnotate::Annotator.new.annotate
    end

    desc 'model [model name]', 'annotate your model'
    def model(model_name)
      options = {}
      OptionParser.new do |opts|
        opts.on("-pPATH", "--path=PATH", "Path to the Rails application") do |path|
          options[:path] = path
        end
      end.parse!

      # abort "Rails application path is required" unless options[:path]
      options[:path] = Dir.pwd unless options[:path]
      p options[:path]
      require File.join(options[:path], 'config', 'environment.rb')

      name = model_name.singularize.camelize
      klass = Object.const_get(name)

      puts 'This is not a model' unless klass < ActiveRecord::Base

      column_names = klass.column_names
      model_dir = 'app/models'
      file_path = "#{model_dir}/#{model_name}.rb"
      file_arr = File.open(file_path).readlines
      file_arr.unshift("# Columns: #{column_names.join(', ')}")
      File.open(file_path, 'w') do |file|
        file_arr.each do |line|
          file.puts line
        end
      end
      puts 'annotate your model'
    end
  end
end
