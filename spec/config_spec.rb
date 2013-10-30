require 'spec_helper'
require 'fakefs/spec_helpers'


describe DirFriend::Config do
  include FakeFS::SpecHelpers

  before(:each) do
    stub_const("DirFriend::Config::CONFIG_PATH", "config.yaml")
    File.write(described_class::CONFIG_PATH, ~<<-EOS)
      default: :theme1
      theme1:
        colorscheme: reds
        layout: fdp
      theme2:
        colorscheme: blues
        layout: dot
    EOS
  end

  describe '#themes' do
    context 'config file exist' do
      it 'read user settings' do
        themes = described_class.new.themes
        expected = { default: :theme1,
                     theme1:{colorscheme:'reds', layout:'fdp'},
                     theme2:{colorscheme:'blues', layout:'dot'} }
        expect(themes).to eq expected
      end
    end

    context 'config file not exist' do
      it 'returns a empty hash' do
        described_class.new.instance_variable_set("@themes", nil)
        stub_const("DirFriend::Config::CONFIG_PATH", "wrong_name_config.yaml")
        themes = described_class.new.themes
        expect(themes).to be_empty
      end
    end
  end

  describe '#read' do
    context 'with nil argument' do
      it 'returns default theme' do
        theme = described_class.read(nil)
        expected = {colorscheme:'reds', layout:'fdp'}
        expect(theme).to eq expected
      end
    end

    context 'with a theme argument' do
      it 'returns the theme' do
        theme = described_class.read(:theme2)
        expected = {colorscheme:'blues', layout:'dot'}
        expect(theme).to eq expected
      end
    end

    context 'when the default value is a hash data' do
      before(:each) do
        File.write(described_class::CONFIG_PATH, ~<<-EOS)
          default:
            layout: fdp
            graph:
              splines: ortho
          theme1:
            colorscheme: reds
            layout: fdp
          theme2:
            colorscheme: blues
            layout: dot
        EOS
      end

      it 'returns the default value' do
        theme = described_class.read(nil)
        expected = {layout:'fdp', graph:{splines:'ortho'}}
        expect(theme).to eq expected
      end
    end
  end
end
