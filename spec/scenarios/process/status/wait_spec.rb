RSpec.describe Process::Status, '.wait' do
  context 'when using the patch' do
    before { load_pty }

    it 'returns the process exit status via Process::Status.wait' do
      spawn_test_with_block { reader.read }
      status = Process::Status.wait
      expect(status).to be_a(described_class)
      expect(status.exitstatus).to eq(42)
    end
  end

  context 'when using Ruby\'s PTY' do
    before { load_pty(:ruby) }

    it 'returns the process exit status via Process::Status.wait' do
      # Here we just simulate an external process that will set Process::Status.wait without using PTY.
      _r, w = IO.pipe
      Process.spawn "#{RbConfig.ruby} #{File.expand_path('spec/pty_compat_test/test_executable')}", out: w, err: %i[child out]
      w.close
      status = Process::Status.wait
      expect(status).to be_a(described_class)
      expect(status.exitstatus).to eq(42)
    end
  end
end
