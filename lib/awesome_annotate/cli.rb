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
      name = model_name.singularize.camelize
      klass = Object.const_get(name)

      puts 'This is not a model' unless klass < ActiveRecord::Base

      column_names = klass.column_names
      model_dir = 'app/models'
      file_path = "#{model_dir}/#{model_name}.rb"
      File.open(file_path, 'r') do |file|
        file.puts "# Columns: #{column_names.join(', ')}"
      end
      puts 'annotate your model'
    end
  end
end
