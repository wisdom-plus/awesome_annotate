# frozen_string_literal: true

require 'awesome_annotate/cli'
require 'active_record'

RSpec.describe AwesomeAnnotate::CLI do
  describe '#annotate' do
    it 'print comment' do
      expect { described_class.new.annotate }.to output("annotate your code\n").to_stdout
    end
  end

  describe '#model' do
    xit do
      class User < ActiveRecord::Base; end
      allow(User).to receive(:column_names).and_return(['id', 'name', 'email', 'created_at', 'updated_at'])

      expect(described_class.new.model('user')).to eq [ 'id', 'name', 'email', 'created_at', 'updated_at']
    end

    it do
      class Post; end
      expect{ described_class.new.model('post') }.to output("annotate your model\nThis is not a model\n").to_stdout
    end
  end
end
