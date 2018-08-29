require 'spec_helper'
require 'quicken/helpers/template'

class TestPlugin
  include Quicken::Helpers::Template
end

RSpec.describe Quicken::Helpers::Template do
  subject { TestPlugin.new }
  let(:template) { 'Test <%= message %> <%= quicken %>' }

  it 'outputs an erb template' do
    subject.parse template
    result = subject.compile message: 'Quicken', quicken: 'test'
    expect(result).to eq 'Test Quicken test'
  end

  it 'outputs an erb template even if not all variables are provided' do
    subject.parse template
    expect(subject.compile message: 'Quicken').to eq 'Test Quicken '
  end
end