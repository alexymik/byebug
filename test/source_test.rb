require_relative 'test_helper'

class TestSource < TestDsl::TestCase

  before { File.open(filename, 'w') do |f|
             f.puts 'break 2'
             f.puts 'break 3 if true'
           end }

  after { FileUtils.rm(filename) }

  let(:filename) { 'source_example.txt' }

  it 'must run commands from file' do
    enter "source #{filename}"
    debug_file 'source' do
      Byebug.breakpoints[0].pos.must_equal 2
      Byebug.breakpoints[1].pos.must_equal 3
      Byebug.breakpoints[1].expr.must_equal 'true'
    end
  end

  it 'must be able to use shortcut' do
    enter "so #{filename}"
    debug_file('source') { Byebug.breakpoints[0].pos.must_equal 2 }
  end

  it 'must show an error if file is not found' do
    enter 'source blabla'
    debug_file 'source'
    check_output_includes /File ".*blabla" not found/, interface.error_queue
  end

  describe 'Help' do
    it 'must show help when used without arguments' do
      enter 'source'
      debug_file 'source'
      check_output_includes \
        "source FILE\texecutes a file containing byebug commands"
    end
  end
end
