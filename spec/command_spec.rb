require 'spec_helper'
require 'fakefs/spec_helpers'

describe DirFriend::Command do
  include FakeFS::SpecHelpers

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  describe '#dot' do
    before(:each) do
      %w(A A/D A/D/G).each { |d| Dir.mkdir d }
      DirFriend::Config.enable = false
    end

    around do |example|
      described_class.no_commands do
        example.run
      end
    end

    describe 'with_open option' do
      context 'on OS X' do
        it 'should be true on default' do
          described_class.
            any_instance.
            should_receive(:run).
            with('open "a.dot"', verbose: false)

          stdout = capture(:stdout) { described_class.start(['dot', 'A']) }
          expect(stdout).to include 'Dot file created:'
        end

        it 'should parse option' do
          described_class.
            any_instance.
            should_not_receive(:run)

          stdout = capture(:stdout) {
            described_class.start(['dot', '--with-open=false', 'A'])
          }
          expect(stdout).to include 'Dot file created:'
        end
      end if DirFriend::OS.mac?

      context 'on Not OS X' do
        before do
          DirFriend::OS.stub(mac?: false)
        end

        it 'should not call open command' do
          described_class.
            any_instance.
            should_not_receive(:run)

          stdout = capture(:stdout) {
            described_class.start(['dot', '--with-open', 'A'])
          }
          expect(stdout).to include 'Dot file created:'
        end
      end
    end
  end
end
