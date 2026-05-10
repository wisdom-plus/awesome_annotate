# frozen_string_literal: true

require 'spec_helper'

require 'awesome_annotate/cli'
require 'active_record'

RSpec.describe AwesomeAnnotate::Model do
  let(:env_file_path) { 'spec/mock/config.rb' }
  let(:model_dir) { 'spec/mock' }
  let(:annotate_model) { described_class.new(env_file_path: env_file_path, model_dir: model_dir) }

  describe '#annotate' do
    context 'when env file path exists' do
      context 'when model is ActiveRecord' do
        it 'write columns in model files' do
          expect do
            annotate_model.annotate('user')
          end.to output(%r{annotate users table columns in spec/mock/user\.rb}).to_stdout
          file_content = File.read("#{model_dir}/user.rb")
          expect(file_content).to include '# == AwesomeAnnotate: columns'
          expect(file_content).to include '# == /AwesomeAnnotate: columns'
          expect(file_content).to include '# == Schema Information'
          expect(file_content).to include '# Table name: users'
          expect(file_content).to include '#  id         :integer  not null, primary key'
          expect(file_content).to include '#  email      :string   not null, default("")'
          expect(file_content).to include '# Indexes'
          expect(file_content).to include '#  (email)       UNIQUE, index_users_on_email'
          expect(file_content).to include '#  (name,email)  index_users_on_name_and_email'
          expect(file_content).to include "# == /AwesomeAnnotate: columns\n\nclass User < ActiveRecord::Base"
        end

        it 'replaces existing annotate block' do
          expect { 2.times { annotate_model.annotate('user') } }.to output(/annotate users table columns/).to_stdout

          file_content = File.read("#{model_dir}/user.rb")
          expect(file_content.scan('# == AwesomeAnnotate: columns').size).to eq 1
          expect(file_content.scan('# == /AwesomeAnnotate: columns').size).to eq 1
          expect(file_content.scan('# == Schema Information').size).to eq 1
        end

        after { file_reset("#{model_dir}/user.rb") }
      end

      context 'when model is not found' do
        it do
          expect { annotate_model.annotate('admin') }.to raise_error(AwesomeAnnotate::NotFoundError)
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

  describe '#annotate_all' do
    context 'when model names are specified' do
      it 'annotates specified models only' do
        expect do
          annotate_model.annotate_all(%w[user])
        end.to output(%r{annotate users table columns in spec/mock/user\.rb}).to_stdout

        user_content = File.read("#{model_dir}/user.rb")
        article_content = File.read("#{model_dir}/article.rb")

        expect(user_content).to include '# Table name: users'
        expect(article_content).not_to include '# == AwesomeAnnotate: columns'
      end

      after { file_reset("#{model_dir}/user.rb") }
    end

    context 'when model names are not specified' do
      it 'discovers and annotates all model files' do
        expect do
          annotate_model.annotate_all
        end.to output(/annotate articles table columns.*annotate users table columns/m).to_stdout

        user_content = File.read("#{model_dir}/user.rb")
        article_content = File.read("#{model_dir}/article.rb")
        application_record_content = File.read("#{model_dir}/application_record.rb")
        concern_content = File.read("#{model_dir}/concerns/auditable.rb")

        expect(user_content).to include '# Table name: users'
        expect(article_content).to include '# Table name: articles'
        expect(application_record_content).not_to include '# == AwesomeAnnotate: columns'
        expect(concern_content).not_to include '# == AwesomeAnnotate: columns'
      end

      after do
        file_reset("#{model_dir}/user.rb")
        file_reset("#{model_dir}/article.rb")
      end
    end
  end

  describe '#remove' do
    it 'removes annotation from a model file' do
      expect { annotate_model.annotate('user') }.to output(/annotate users table columns/).to_stdout

      expect { annotate_model.remove('user') }.to output(%r{remove model annotation in spec/mock/user\.rb}).to_stdout

      file_content = File.read("#{model_dir}/user.rb")
      expect(file_content).not_to include '# == AwesomeAnnotate: columns'
      expect(file_content).to include 'class User < ActiveRecord::Base'
    end
  end

  describe '#remove_all' do
    it 'removes annotations from discovered model files' do
      expect do
        annotate_model.annotate_all
      end.to output(/annotate articles table columns.*annotate users table columns/m).to_stdout

      expect do
        annotate_model.remove_all
      end.to output(
        %r{remove model annotation in spec/mock/article\.rb.*remove model annotation in spec/mock/user\.rb}m
      ).to_stdout

      user_content = File.read("#{model_dir}/user.rb")
      article_content = File.read("#{model_dir}/article.rb")

      expect(user_content).not_to include '# == AwesomeAnnotate: columns'
      expect(article_content).not_to include '# == AwesomeAnnotate: columns'
    end
  end
end
