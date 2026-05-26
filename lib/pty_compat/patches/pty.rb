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
