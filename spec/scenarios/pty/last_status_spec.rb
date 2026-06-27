RSpec.describe 'PTY', '.last_status' do
  context 'when using the patch' do
    before { load_pty }

    it 'returns the process exit status via PTY.last_status' do
      spawn_test_with_block { reader.read }
      status = PTY.last_status
      expect(status).to be_a(Process::Status)
      expect(status.exitstatus).to eq(42)
    end
  end

  context 'when using Ruby\'s PTY' do
    before { load_pty(:ruby) }

    it 'returns the process exit status via PTY.last_status' do
      # Here we just simulate an external process without using PTY.
      `#{RbConfig.ruby} #{File.expand_path('spec/pty_compat_test/test_executable')} nostderr`
      status = PTY.last_status
      expect(status).to be_a(Process::Status)
      expect(status.exitstatus).to eq(42)
    end
  end
end
