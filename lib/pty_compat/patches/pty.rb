require 'English'

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

    module Process
      class Status
        class << self
          # Fallback on getting process status from POpen3
          prepend PtyCompat::ProcessStatusFromPopen3
        end
      end
    end
  end
end
