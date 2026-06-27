RSpec.shared_examples 'Ruby\'s PTY.spawn' do |opts|
  # Options should have the following properties:
  # - with_test_run [#call(example, *args, &)] Code use to run the test executable with arguments and yield the expectations.

  # @return [Hash{Symbol => Object}] The shared examples options, now accessible to examples' helpers
  attr_reader :opts

  before do
    @opts = opts
  end

  # Execute the test executable with arguments and yield a block for expectations
  def with_test_run(...)
    opts[:with_test_run].call(self, ...)
  end

  it 'returns reader (IO), writer (IO) and pid (Integer)' do
    with_test_run do
      expect(reader).to be_a(IO)
      expect(writer).to be_a(IO)
      expect(pid).to be_a(Integer)
    end
  end

  it 'captures stdout from the spawned process' do
    with_test_run { expect(reader.read).to include('STDOUT: Hello from stdout') }
  end

  it 'captures stderr from the spawned process' do
    with_test_run { expect(reader.read).to include('STDERR: Hello from stderr') }
  end

  it 'sends data to stdin which the spawned process receives' do
    with_test_run('stdin') do
      writer.puts 'Hello from stdin'
      expect(reader.read).to include('STDIN: Hello from stdin')
    end
  end
end
