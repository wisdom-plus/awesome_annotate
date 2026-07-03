# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe AwesomeAnnotate::Configuration do
  describe '.load' do
    it 'returns default options when the config file does not exist' do
      config = described_class.load('missing.yml')

      expect(config.options).to eq(
        env_file_path: 'config/environment.rb',
        model_dir: 'app/models',
        route_file_path: 'config/routes.rb',
        annotation_position: 'top',
        exclude_model_files: [],
        include_indexes: true,
        exclude_columns: [],
        include_column_defaults: true
      )
    end

    it 'loads supported options from a YAML config file' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'awesome_annotate.yml')
        File.write(path, <<~YAML)
          env_file_path: spec/mock/config.rb
          model_dir: spec/mock
          route_file_path: spec/mock/routes.rb
          annotation_position: bottom
          exclude_model_files:
            - article.rb
            - legacy/*
          include_indexes: false
          exclude_columns:
            - encrypted_password
            - reset_password_token
          include_column_defaults: false
          unknown_option: ignored
        YAML

        config = described_class.load(path)

        expect(config.options).to eq(
          env_file_path: 'spec/mock/config.rb',
          model_dir: 'spec/mock',
          route_file_path: 'spec/mock/routes.rb',
          annotation_position: 'bottom',
          exclude_model_files: ['article.rb', 'legacy/*'],
          include_indexes: false,
          exclude_columns: %w[encrypted_password reset_password_token],
          include_column_defaults: false
        )
      end
    end

    it 'raises when the config file is not a YAML mapping' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'awesome_annotate.yml')
        File.write(path, "- value\n")

        expect { described_class.load(path) }.to raise_error(
          ArgumentError,
          "Configuration file must contain a YAML mapping: #{path}"
        )
      end
    end

    it 'raises when annotation_position is invalid' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'awesome_annotate.yml')
        File.write(path, "annotation_position: middle\n")

        expect { described_class.load(path) }.to raise_error(
          ArgumentError,
          'annotation_position must be one of: top, bottom'
        )
      end
    end

    it 'raises when exclude_model_files is not an array' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'awesome_annotate.yml')
        File.write(path, "exclude_model_files: article.rb\n")

        expect { described_class.load(path) }.to raise_error(
          ArgumentError,
          'exclude_model_files must be an array'
        )
      end
    end

    it 'raises when include_indexes is not a boolean' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'awesome_annotate.yml')
        File.write(path, "include_indexes: maybe\n")

        expect { described_class.load(path) }.to raise_error(
          ArgumentError,
          'include_indexes must be true or false'
        )
      end
    end

    it 'raises when exclude_columns is not an array' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'awesome_annotate.yml')
        File.write(path, "exclude_columns: encrypted_password\n")

        expect { described_class.load(path) }.to raise_error(
          ArgumentError,
          'exclude_columns must be an array'
        )
      end
    end

    it 'raises when include_column_defaults is not a boolean' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'awesome_annotate.yml')
        File.write(path, "include_column_defaults: maybe\n")

        expect { described_class.load(path) }.to raise_error(
          ArgumentError,
          'include_column_defaults must be true or false'
        )
      end
    end
  end

  describe '.create' do
    it 'creates a default config file' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'config/initializers/awesome_annotate.yml')

        described_class.create(path)

        content = File.read(path)
        expect(content).to include('annotation_position: top')
        expect(content).to include('exclude_model_files: []')
        expect(content).to include('include_indexes: true')
        expect(content).to include('exclude_columns: []')
        expect(content).to include('include_column_defaults: true')
      end
    end
  end
end
