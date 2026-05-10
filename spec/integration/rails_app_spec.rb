# frozen_string_literal: true

require 'fileutils'
require 'spec_helper'
require 'tmpdir'

require 'awesome_annotate/model'
require 'awesome_annotate/route'

RSpec.describe 'Rails application annotation' do
  let(:fixture_app_path) { File.expand_path('../fixtures/rails_app', __dir__) }

  around do |example|
    Dir.mktmpdir do |tmpdir|
      FileUtils.cp_r("#{fixture_app_path}/.", tmpdir)

      Dir.chdir(tmpdir) do
        example.run
      end
    end
  end

  it 'annotates a model file in a Rails-like application root' do
    annotator = AwesomeAnnotate::Model.new

    expect { 2.times { annotator.annotate('user') } }.to output(/annotate users table columns/).to_stdout

    model_content = File.read('app/models/user.rb')
    expect(model_content.scan('# == AwesomeAnnotate: columns').size).to eq 1
    expect(model_content.scan('# == /AwesomeAnnotate: columns').size).to eq 1
    expect(model_content).to include '# == Schema Information'
    expect(model_content).to include '#  id         :integer  not null, primary key'
    expect(model_content).to include '#  (email)       UNIQUE, index_users_on_email'
    expect(model_content).to include 'class User < ActiveRecord::Base'
  end

  it 'annotates a routes file in a Rails-like application root' do
    annotator = AwesomeAnnotate::Route.new

    expect { 2.times { annotator.annotate } }.to output(%r{annotate routes in config/routes\.rb}).to_stdout

    route_content = File.read('config/routes.rb')
    expect(route_content.scan('# == AwesomeAnnotate: routes').size).to eq 1
    expect(route_content.scan('# == /AwesomeAnnotate: routes').size).to eq 1
    expect(route_content).to include '# users GET /users(.:format) users#index'
    expect(route_content).to include 'Rails.application.routes.draw do'
  end

  it 'annotates discovered model files in a Rails-like application root' do
    annotator = AwesomeAnnotate::Model.new

    expect do
      annotator.annotate_all
    end.to output(/annotate articles table columns.*annotate users table columns/m).to_stdout

    user_content = File.read('app/models/user.rb')
    article_content = File.read('app/models/article.rb')
    application_record_content = File.read('app/models/application_record.rb')
    concern_content = File.read('app/models/concerns/auditable.rb')

    expect(user_content).to include '# Table name: users'
    expect(article_content).to include '# Table name: articles'
    expect(application_record_content).not_to include '# == AwesomeAnnotate: columns'
    expect(concern_content).not_to include '# == AwesomeAnnotate: columns'
  end

  it 'annotates all models and routes in a Rails-like application root' do
    expect do
      AwesomeAnnotate::CLI.new.all
    end.to output(/annotate articles table columns.*annotate users table columns.*annotate routes/m).to_stdout

    user_content = File.read('app/models/user.rb')
    article_content = File.read('app/models/article.rb')
    route_content = File.read('config/routes.rb')

    expect(user_content).to include '# Table name: users'
    expect(article_content).to include '# Table name: articles'
    expect(route_content).to include '# == AwesomeAnnotate: routes'
  end

  it 'removes all model and route annotations in a Rails-like application root' do
    expect do
      AwesomeAnnotate::CLI.new.all
    end.to output(/annotate articles table columns.*annotate users table columns.*annotate routes/m).to_stdout

    expect do
      AwesomeAnnotate::CLI.start(%w[remove all])
    end.to output(/remove model annotation.*remove route annotation/m).to_stdout

    user_content = File.read('app/models/user.rb')
    article_content = File.read('app/models/article.rb')
    route_content = File.read('config/routes.rb')

    expect(user_content).not_to include '# == AwesomeAnnotate: columns'
    expect(article_content).not_to include '# == AwesomeAnnotate: columns'
    expect(route_content).not_to include '# == AwesomeAnnotate: routes'
  end
end
