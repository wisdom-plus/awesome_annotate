# frozen_string_literal: true

require 'awesome_annotate/cli'
require 'active_record'
require 'tmpdir'

RSpec.describe AwesomeAnnotate::CLI do
  describe '#print_version' do
    it do
      expect { described_class.new.print_version }.to output("#{AwesomeAnnotate::VERSION}\n").to_stdout
    end
  end

  describe '#models' do
    it 'delegates model names to model annotator' do
      annotator = instance_double(AwesomeAnnotate::Model)
      allow(AwesomeAnnotate::Model).to receive(:new).and_return(annotator)
      allow(annotator).to receive(:annotate_all)

      described_class.new.models('user', 'article')

      expect(annotator).to have_received(:annotate_all).with(%w[user article])
    end

    it 'passes config options to the model annotator' do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          FileUtils.mkdir_p('config/initializers')
          File.write('config/initializers/awesome_annotate.yml', <<~YAML)
            env_file_path: spec/mock/config.rb
            model_dir: spec/mock
            route_file_path: spec/mock/routes.rb
            annotation_position: bottom
            exclude_model_files:
              - article.rb
            include_indexes: false
            exclude_columns:
              - email
            include_column_defaults: false
            exclude_routes:
              - '*private_policy*'
          YAML
          annotator = instance_double(AwesomeAnnotate::Model, annotate_all: nil)
          allow(AwesomeAnnotate::Model).to receive(:new).and_return(annotator)

          described_class.new.models('user')

          expect(AwesomeAnnotate::Model).to have_received(:new).with(
            env_file_path: 'spec/mock/config.rb',
            model_dir: 'spec/mock',
            route_file_path: 'spec/mock/routes.rb',
            annotation_position: 'bottom',
            exclude_model_files: ['article.rb'],
            include_indexes: false,
            exclude_columns: ['email'],
            include_column_defaults: false,
            exclude_routes: ['*private_policy*']
          )
        end
      end
    end
  end

  describe '#init' do
    it 'creates a config file' do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          expect do
            described_class.new.init
          end.to output("create config/initializers/awesome_annotate.yml\n").to_stdout

          expect(File.read('config/initializers/awesome_annotate.yml')).to include(
            'exclude_routes: []'
          )
        end
      end
    end

    it 'does not overwrite an existing config file' do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          FileUtils.mkdir_p('config/initializers')
          File.write('config/initializers/awesome_annotate.yml', "model_dir: custom/models\n")

          expect { described_class.new.init }.to output(
            "Config file already exists: config/initializers/awesome_annotate.yml\n"
          ).to_stdout
          expect(File.read('config/initializers/awesome_annotate.yml')).to eq("model_dir: custom/models\n")
        end
      end
    end
  end

  describe '#all' do
    it 'annotates all models and routes' do
      model_annotator = instance_double(AwesomeAnnotate::Model)
      route_annotator = instance_double(AwesomeAnnotate::Route)
      allow(AwesomeAnnotate::Model).to receive(:new).and_return(model_annotator)
      allow(AwesomeAnnotate::Route).to receive(:new).and_return(route_annotator)
      allow(model_annotator).to receive(:annotate_all)
      allow(route_annotator).to receive(:annotate)

      described_class.new.all

      expect(model_annotator).to have_received(:annotate_all)
      expect(route_annotator).to have_received(:annotate)
    end
  end

  describe 'AwesomeAnnotate::Remove#all' do
    it 'removes all model and route annotations' do
      model_annotator = instance_double(AwesomeAnnotate::Model)
      route_annotator = instance_double(AwesomeAnnotate::Route)
      allow(AwesomeAnnotate::Model).to receive(:new).and_return(model_annotator)
      allow(AwesomeAnnotate::Route).to receive(:new).and_return(route_annotator)
      allow(model_annotator).to receive(:remove_all)
      allow(route_annotator).to receive(:remove)

      AwesomeAnnotate::Remove.new.all

      expect(model_annotator).to have_received(:remove_all)
      expect(route_annotator).to have_received(:remove)
    end

    it 'passes config options to remove annotators' do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          FileUtils.mkdir_p('config/initializers')
          File.write('config/initializers/awesome_annotate.yml', "model_dir: spec/mock\n")
          model_annotator = instance_double(AwesomeAnnotate::Model, remove_all: nil)
          route_annotator = instance_double(AwesomeAnnotate::Route, remove: nil)
          allow(AwesomeAnnotate::Model).to receive(:new).and_return(model_annotator)
          allow(AwesomeAnnotate::Route).to receive(:new).and_return(route_annotator)

          AwesomeAnnotate::Remove.new.all

          expect(AwesomeAnnotate::Model).to have_received(:new).with(
            env_file_path: 'config/environment.rb',
            model_dir: 'spec/mock',
            route_file_path: 'config/routes.rb',
            annotation_position: 'top',
            exclude_model_files: [],
            include_indexes: true,
            exclude_columns: [],
            include_column_defaults: true,
            exclude_routes: []
          )
          expect(AwesomeAnnotate::Route).to have_received(:new).with(
            env_file_path: 'config/environment.rb',
            model_dir: 'spec/mock',
            route_file_path: 'config/routes.rb',
            annotation_position: 'top',
            exclude_model_files: [],
            include_indexes: true,
            exclude_columns: [],
            include_column_defaults: true,
            exclude_routes: []
          )
        end
      end
    end
  end
end
