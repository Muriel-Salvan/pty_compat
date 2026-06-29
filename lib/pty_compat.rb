require 'zeitwerk'

Zeitwerk::Loader.for_gem.setup

# Provide ways to implement Ruby's PTY's interface on all platofrms.
module PtyCompat
end

# Make sure PTY is loaded with eventual fallbacks.
require 'pty_compat/patches/pty'
