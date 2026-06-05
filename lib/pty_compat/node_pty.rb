require 'open3'

module PtyCompat
  # Provide a similar interface as the PTY one that could work on platforms that don't support PTY (for example Windows).
  # Internally uses NodeJS's node-pty.
  module NodePty
    # Spawn a command in a PTY and return or yield its outputs, input and pid
    #
    # @param args [Array] The command arguments to execute (see ::PTY#spawn)
    # @yield An optional code called with all PTY outputs, input and PID.
    # @yieldparam r [IO] The reader output (containing stdout and stderr).
    # @yieldparam w [IO] The writer input (containing stdin).
    # @yieldparam pid [Integer] The process PID.
    # @return [Array<IO, Integer>, nil] The reader, writer and PID of the process, or nil if used with a yielded block.
    #   - r [IO] The reader output (containing stdout and stderr).
    #   - w [IO] The writer input (containing stdin).
    #   - pid [Integer] The process PID.
    def spawn(*args)
      env, cmd = args.first.is_a?(Hash) ? [[args.first], args[1..]] : [[], args]
      node_args = env + ['node', "#{__dir__}/assets/node_pty_bridge.js"] + cmd
      if block_given?
        Open3.popen3(*node_args) do |stdin, stdout, stderr, wait_thr|
          @last_wait_thr = wait_thr
          yield popen3_to_pty(stdin, stdout, stderr, wait_thr)
        end
      else
        stdin, stdout, stderr, wait_thr = Open3.popen3(*node_args)
        @last_wait_thr = wait_thr
        popen3_to_pty(stdin, stdout, stderr, wait_thr)
      end
    end

    # @return [Process::Status] Last process status
    def last_status
      @last_wait_thr.value
    end

    private

    # Convert the popen3 descriptors to PTY ones
    #
    # @param stdin [IO] The stdin descriptor
    # @param stdout [IO] The stdout descriptor
    # @param stderr [IO] The stderr descriptor
    # @param wait_thread [Process::Waiter] The process information
    # @return [Array<IO, Integer>] The corresponding PTY reader, writer and PID.
    #   - r [IO] The reader output (containing stdout and stderr).
    #   - w [IO] The writer input (containing stdin).
    #   - pid [Integer] The process PID.
    def popen3_to_pty(stdin, stdout, stderr, wait_thread)
      # Create a pipe to combine stdout and stderr into a single IO
      combined_r, combined_w = IO.pipe
      # Reader thread for stdout
      stdout_reader = Thread.new do
        IO.copy_stream(stdout, combined_w)
      rescue IOError
        # Ignore errors from closed pipe
      ensure
        begin
          stdout.close
        rescue RuntimeError
          nil
        end
      end
      # Reader thread for stderr
      stderr_reader = Thread.new do
        IO.copy_stream(stderr, combined_w)
      rescue IOError
        # Ignore errors from closed pipe
      ensure
        begin
          stderr.close
        rescue RuntimeError
          nil
        end
      end
      # Closer thread: close the write end of the combined pipe once both stdout and stderr have finished being read.
      Thread.new do
        stdout_reader.join
        stderr_reader.join
        begin
          combined_w.close
        rescue RuntimeError
          nil
        end
      end
      [combined_r, stdin, wait_thread.pid]
    end
  end
end
