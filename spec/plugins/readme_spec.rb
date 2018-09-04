# frozen_string_literal: true

require 'spec_helper'
require 'quicken/plugins/readme'

RSpec.describe Quicken::Plugins::Readme do
  let(:default_args) { { project_name: 'Test', author_name: 'Test', author_email: 'test@example.com', description: 'This is a test' } }
  let(:file) { double :file, close: nil }

  before do
    allow(File).to receive(:new).and_return file
    # allow(file).to receive(:write).with(an_instance_of(String))
  end

  it 'writes a README with the default template' do
    allow(File).to receive(:exist?).and_return false
    plugin = described_class.new default_args

    expect(file).to receive(:write).with(<<~README
      # Test
      ### by Test <test@example.com>
      ---
      This is a test
    README
.chop)

    plugin.call
  end
end
