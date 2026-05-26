require_relative 'lib/pty_compat/version'

Gem::Specification.new do |spec|
  spec.name          = 'pty_compat'
  spec.version       = PtyCompat::VERSION
  spec.summary       = 'Make Ruby\'s PTY work on all platforms'
  spec.homepage      = 'https://github.com/Muriel-Salvan/pty_compat'
  spec.license       = 'BSD-3-Clause'

  spec.author        = 'Muriel Salvan'
  spec.email         = 'muriel@x-aeon.com'

  spec.files         = Dir['*.{md,txt}', '{lib}/**/*']
  spec.executables   = Dir['bin/*'].map { |exe_file| File.basename(exe_file) }
  spec.require_path  = 'lib'

  spec.required_ruby_version = '>= 3.1'

  spec.add_dependency 'zeitwerk', '~> 2.7'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
