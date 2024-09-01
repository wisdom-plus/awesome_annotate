#frozen_string_literal: true
require 'spec_helper'

require 'awesome_annotate/cli'
require 'active_record'

RSpec.describe AwesomeAnnotate::Route do
  let(:env_file_path) { 'spec/mock/config.rb'}
  let(:route_file_path) { 'spec/mock/routes.rb'}
  let(:annotate_model) { described_class.new(env_file_path:, route_file_path:) }
  let(:routes_message) { File.readlines('spec/support/routes_message.txt').join }

  def parse_routes(routes)
    split_routes = routes.split(/\r\n|\r|\n/)
    parse_routes = split_routes.map do |route|
      "# #{route}\n"
    end
    parse_routes.push("\n")
    parse_routes.unshift("#---This is route annotate---\n#\n")
    parse_routes.join
  end

  describe '#annotate' do
    context 'when env file path exists' do
      context 'when route file path exists' do
        before do
          route_mock(routes_message)
        end

        it 'write route annotate in routes file' do
          expect { annotate_model.annotate }.to output(/annotate routes in spec\/mock\/routes\.rb/).to_stdout
          file_content = File.read(route_file_path)
          expect(file_content).to include parse_routes(routes_message)
        end

        after { file_reset(route_file_path, true) }
      end

      context 'when route file path does not exist' do
        let(:route_file_path) { nil }

        before do
          route_mock(routes_message)
        end

        it 'raise error' do
          expect { annotate_model.annotate }.to raise_error(RuntimeError, 'Route file not found')
        end
      end
    end

    context 'when env file path does not exist' do
      let(:env_file_path) { nil }

      it do
        expect { annotate_model.annotate }.to raise_error(RuntimeError, 'Rails application path is required')
      end
    end
  end
end
