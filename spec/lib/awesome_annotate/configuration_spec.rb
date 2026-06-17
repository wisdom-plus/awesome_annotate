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
        annotation_position: 'top'
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
          unknown_option: ignored
        YAML

        config = described_class.load(path)

        expect(config.options).to eq(
          env_file_path: 'spec/mock/config.rb',
          model_dir: 'spec/mock',
          route_file_path: 'spec/mock/routes.rb',
          annotation_position: 'bottom'
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
  end

  describe '.create' do
    it 'creates a default config file' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'config/initializers/awesome_annotate.yml')

        described_class.create(path)

        expect(File.read(path)).to include('annotation_position: top')
      end
    end
  end
end
