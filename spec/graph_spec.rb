require 'spec_helper'
require 'fakefs/spec_helpers'

describe DirFriend::Graph do
  include FakeFS::SpecHelpers

  before(:each) do
    %w(A A/D A/D/G).each { |d| Dir.mkdir d }
    %w(A/a A/b A/c A/D/e A/D/f A/D/G/h A/D/G/i).each { |f| File.write(f, '') }
    @d = DirFriend::D.new('A')
  end

  describe '#render' do
    it 'reutrns dot data w/o opt' do
      g = DirFriend::Graph.new(@d).render
      words = %w(digraph)
      test = words.all? { |w| g.include? w }
      expect(test).to be_true
    end

    it 'reutrns dot data with layout, colorscheme, and node shape data' do
      opt = {layout:'fdp', colorscheme:'greens', nodes:{shape:'box'}}
      g = DirFriend::Graph.new(@d).render(opt)
      words = %w(colorscheme="greens4" layout="fdp" shape="box")
      test = words.all? { |w| g.include? w }
      expect(test).to be_true
    end
  end
end
