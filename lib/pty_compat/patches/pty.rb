require 'English'

# Augment PTY module with last_status
module PTY
  # @!group Public API

  # @return [Process::Status] Last process status.
  #   Use this instead of $? as some workaround methods don't set $? properly and we can't modify this variable.
  def self.last_status
    # Default implementation
    $CHILD_STATUS
  end
end

begin
  require 'pty'
rescue LoadError => e
  if e.message == 'cannot load such file -- pty'
    module PTY
      class << self
        # Fallback on node-pty
        prepend PtyCompat::NodePty
      end
    end
  end
end
