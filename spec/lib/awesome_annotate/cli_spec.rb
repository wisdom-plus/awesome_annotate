# frozen_string_literal: true

require 'awesome_annotate/cli'
require 'active_record'

RSpec.describe AwesomeAnnotate::CLI do
  describe '#print_version' do
    it do
      expect { described_class.new.print_version }.to output("#{AwesomeAnnotate::VERSION}\n").to_stdout
    end
  end
end
