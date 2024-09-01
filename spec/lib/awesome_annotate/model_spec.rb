#frozen_string_literal: true
require 'spec_helper'

require 'awesome_annotate/cli'
require 'active_record'

RSpec.describe AwesomeAnnotate::Model do
  let(:env_file_path) { 'spec/mock/config.rb'}
  let(:model_dir) { 'spec/mock'}
  let(:annotate_model) { described_class.new(env_file_path:, model_dir:) }

  describe '#annotate' do
    context 'when env file path exists' do
      context 'when model is ActiveRecord' do
        it 'write columns in model files' do
          expect { annotate_model.annotate('user') }.to output(/annotate users table columns in spec\/mock\/user\.rb/).to_stdout
          file_content = File.read("#{model_dir}/user.rb")
          expect(file_content).to include "Columns: id, name, email, created_at, updated_at"
        end

        after { file_reset("#{model_dir}/user.rb", false) }
      end

      context 'when model is not found' do
        it do
          expect { annotate_model.annotate('admin') }.to raise_error(NotFoundError)
        end
      end

      context 'when model is not ActiveRecord' do
        it do
          expect { annotate_model.annotate('post') }.to output(/This model does not inherit activerecord/).to_stdout
        end
      end

    end

    context 'when env file path does not exist' do
      let(:env_file_path) { nil }

      it do
        expect { annotate_model.annotate('user') }.to raise_error(RuntimeError, 'Rails application path is required')
      end
    end
  end
end
