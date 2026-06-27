module PtyCompatTest
  module Helpers
    # Load the PTY compatibility layer with the specified backend flavor.
    #
    # This helper sets up the test environment for PTY specs by stubbing the `require`
    # method and loading the PTY patch file. Two flavors are supported:
    #
    # @param flavor [Symbol] The backend flavor to simulate:
    #   * `:node_pty` (default) — Simulates the node-pty backend by raising a LoadError
    #     when `require 'pty'` is called. This ensures the PTY compat layer falls back
    #     to its own implementation.
    #   * `:ruby` — Simulates Ruby's native PTY being available by stubbing
    #     `require 'pty'` to succeed.
    #
    # @example Using the default node-pty flavor
    #   `before { load_pty }`
    #
    # @example Using the Ruby PTY flavor
    #   `before { load_pty(:ruby) }`
    #
    # @raise [ArgumentError] if an unsupported flavor is provided
    def load_pty(flavor = :node_pty)
      allow(TOPLEVEL_BINDING.receiver).to receive(:require).and_call_original
      case flavor
      when :node_pty
        allow(TOPLEVEL_BINDING.receiver).to receive(:require).with('pty') { raise LoadError, 'cannot load such file -- pty' }
      when :ruby
        allow(TOPLEVEL_BINDING.receiver).to receive(:require).with('pty')
      else
        raise ArgumentError, "Unknown PTY flavor: #{flavor}."
      end
      load 'lib/pty_compat/patches/pty.rb'
    end

    # Run the test executable using PTY.spawn without a block and set variables for testing.
    # Yield to a code for assertions, and then automatically close readers and writers.
    #
    # @args [Array<String>] Additional arguments to pass to the executable test
    # @yield Optional code called after running the test executable
    def spawn_test_without_block(*args)
      @reader, @writer, @pid = PTY.spawn(RbConfig.ruby, File.expand_path('spec/pty_compat_test/test_executable'), *args)
      begin
        yield if block_given?
      ensure
        reader.close
        writer.close
      end
    end

    # Run the test executable using PTY.spawn with a block and set variables for testing.
    # The block form automatically closes the IOs when the block exits.
    #
    # @args [Array<String>] Additional arguments to pass to the executable test
    # @yield Optional code called after running the test executable
    def spawn_test_with_block(*args)
      PTY.spawn(RbConfig.ruby, File.expand_path('spec/pty_compat_test/test_executable'), *args) do |new_reader, new_writer, new_pid|
        @reader = new_reader
        @writer = new_writer
        @pid = new_pid
        yield if block_given?
      end
    end

    # @return [IO] The reader returned by the last call to PTY.spawn
    attr_reader :reader

    # @return [IO] The writer returned by the last call to PTY.spawn
    attr_reader :writer

    # @return [Integer] The PID returned by the last call to PTY.spawn
    attr_reader :pid
  end
end
