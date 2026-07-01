module PtyCompat
  # Provide a similar interface as the Process::Status.wait one that can return the PoOpen3 last process status,
  # so that it works the same as Ruby's native PTY interface.
  module ProcessStatusFromPopen3
    # Wait for the last pid to end and return the corresponding Process Status.
    #
    # @param pid [Integer] PID to wait for
    # @param flags [Integer] Flags
    # @return [Process::Status] Corresponding process status
    def wait(pid = -1, flags = 0)
      if pid == -1 && flags.zero? && PTY.last_wait_thr
        PTY.last_wait_thr.value
      else
        super
      end
    end
  end
end
