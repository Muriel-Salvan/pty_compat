require_relative 'shared_examples/pty_spawn'

RSpec.describe 'PTY', '.spawn' do
  before { load_pty }

  describe 'non-block form' do
    it_behaves_like(
      'Ruby\'s PTY.spawn',
      with_test_run: proc { |example, *args, &block| example.spawn_test_without_block(*args, &block) }
    )
  end

  describe 'block form' do
    it_behaves_like(
      'Ruby\'s PTY.spawn',
      with_test_run: proc { |example, *args, &block| example.spawn_test_with_block(*args, &block) }
    )
  end
end
