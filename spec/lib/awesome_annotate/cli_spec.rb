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
end
