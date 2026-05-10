# frozen_string_literal: true

require 'awesome_annotate/cli'
require 'active_record'

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
end
