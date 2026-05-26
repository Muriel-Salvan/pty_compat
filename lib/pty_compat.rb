require 'zeitwerk'

Zeitwerk::Loader.for_gem.setup

# Make sure PTY is loaded with eventual fallbacks.
require 'pty_compat/patches/pty'
