require 'spec_helper'
require 'fakefs/spec_helpers'

describe DirFriend::Config do
  include FakeFS::SpecHelpers

  before(:each) do
    stub_const("DirFriend::Config::CONFIG_PATH", "config.yaml")
    File.write(described_class::CONFIG_PATH, ~<<-EOS)
      default: :theme1
      theme1:
        color: reds
        shape: box
    EOS
  end

  describe '.themes' do
    context 'config file exist' do
      it 'read user settings' do
        themes = described_class.send(:themes)
        expected = {default: :theme1, theme1:{color:'reds', shape:'box'}}
        expect(themes).to eq expected
      end
    end
  end
end