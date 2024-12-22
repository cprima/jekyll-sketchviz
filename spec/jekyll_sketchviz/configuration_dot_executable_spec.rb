# frozen_string_literal: true

require 'jekyll_sketchviz/configuration'
require 'open3'

RSpec.describe JekyllSketchviz::Configuration do
  let(:default_dot_path) { 'dot' } # Default executable.
  let(:user_dot_path) { 'neato' } # User-provided executable (alternative to `dot`).
  let(:mock_config) do
    {
      executable: { dot: user_dot_path }
    }
  end
  let(:site) { instance_double(Jekyll::Site, config: { 'sketchviz' => mock_config }) }

  describe 'Executable validation' do
    context 'when using the default dot executable' do
      it 'validates the default dot executable successfully' do
        allow(Open3).to receive(:capture2).with("#{default_dot_path} -V")
                                          .and_return(['dot - graphviz version',
                                                       instance_double(Process::Status, success?: true)])
        expect(dot_executable_valid?(default_dot_path)).to be(true)
      end
    end

    context 'when using a user-provided executable' do
      it 'validates the user-configured executable successfully' do
        allow(Open3).to receive(:capture2).with("#{user_dot_path} -V")
                                          .and_return(['neato - graphviz version',
                                                       instance_double(Process::Status, success?: true)])
        expect(dot_executable_valid?(user_dot_path)).to be(true)
      end
    end

    context 'when the user-provided executable is invalid' do
      let(:user_dot_path) { '/invalid/path/to/neato' }

      it 'returns false for an invalid executable' do
        allow(Open3).to receive(:capture2).with("#{user_dot_path} -V").and_raise(Errno::ENOENT)
        expect(dot_executable_valid?(user_dot_path)).to be(false)
      end
    end

    context 'when the executable fails to run' do
      it 'returns false for execution errors' do
        allow(Open3).to receive(:capture2).with("#{user_dot_path} -V")
                                          .and_return(['Error message',
                                                       instance_double(Process::Status, success?: false)])
        expect(dot_executable_valid?(user_dot_path)).to be(false)
      end
    end
  end

  # Helper method to validate dot executable
  def dot_executable_valid?(path)
    output, status = Open3.capture2("#{path} -V")
    status.success? && output.match?(/graphviz/i)
  rescue Errno::ENOENT
    false
  end
end
