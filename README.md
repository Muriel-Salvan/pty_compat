<div align="center">

# pty_compat

Make Ruby's `PTY` work on all platforms, including Windows

[![License](https://img.shields.io/github/license/Muriel-Salvan/pty_compat?style=for-the-badge)](https://github.com/Muriel-Salvan/pty_compat/blob/main/LICENSE)
[![Gem Version](https://img.shields.io/gem/v/pty_compat?style=for-the-badge)](https://rubygems.org/gems/pty_compat)
[![CI](https://img.shields.io/github/actions/workflow/status/Muriel-Salvan/pty_compat/continuous_integration.yml?style=for-the-badge)](https://github.com/Muriel-Salvan/pty_compat/actions)
[![Stars](https://img.shields.io/github/stars/Muriel-Salvan/pty_compat?style=for-the-badge)](https://github.com/Muriel-Salvan/pty_compat/stargazers)

</div>

## What is this?

Ruby's built-in `PTY` module is not available on Windows. `pty_compat` transparently replaces it with an equivalent implementation using [`node-pty`](https://github.com/microsoft/node-pty), so your code works everywhere without changes.

A single `require 'pty_compat'` patches `PTY.spawn` to fall back to a Node.js bridge when the native module is unavailable. No migration, no conditional logic, no platform checks.

## Table of contents

- [What is this?](#what-is-this)
- [Quick Start](#quick-start)
  - [Installation](#installation)
  - [Usage](#usage)
- [Requirements](#requirements)
- [Features](#features)
- [Public API](#public-api)
- [Documentation](#documentation)
- [How it works](#how-it-works)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Quick Start

### Installation

```sh
bundle add pty_compat
```

If you're not using Bundler:

```sh
gem install pty_compat
```

On Windows, you also need `node-pty`:

```sh
npm install node-pty
```

> [!TIP]
> If your project does not use Node.js, you can install `node-pty` locally. The bridge script resolves it from the current working directory.

### Usage

```ruby
require 'pty_compat'

# Non-block form
reader, writer, pid = PTY.spawn('ping', '-c', '3', 'example.com')
writer.puts('input')
reader.each_line { |line| puts line }
Process.wait(pid)

# Block form
PTY.spawn('ping', '-c', '3', 'example.com') do |reader, writer, pid|
  writer.puts('input')
  reader.each_line { |line| puts line }
end

# Retrieve the exit status portably
status = PTY.last_status
```

## Requirements

- Ruby >= 3.1
- Node.js and `node-pty` (only required on platforms without native `PTY` support, typically Windows)

## Features

- **Zero-config drop-in.** A single `require` replaces `PTY.spawn` on Windows — no configuration, no platform checks, no conditional logic.
- **Portable exit status.** Use `PTY.last_status` to retrieve the exit code on any platform instead of relying on `$?`.
- **Non-block & block forms.** Supports both `PTY.spawn(command, args...) -> [reader, writer, pid]` and `PTY.spawn(command, args...) { |reader, writer, pid| ... }` forms.
- **Windows support.** Leverages Microsoft's [`node-pty`](https://github.com/microsoft/node-pty) to provide a proper PTY on Windows, where Ruby's native `PTY` is unavailable.
- **Lightweight.** The Ruby codebase is minimal, delegating the heavy lifting to a well-maintained native module.
- **Works on all platforms.** Falls back to the `node-pty` bridge only when the native `PTY` module is unavailable; otherwise uses the standard library unchanged.

## Public API

### `PTY.spawn(command, *args) -> [reader, writer, pid]`

Spawns a new process attached to a pseudo-terminal.

| Parameter | Type | Description |
|-----------|------|-------------|
| `command` | `String` | The command to execute (e.g. `'ping'`). |
| `*args` | `String...` | Zero or more arguments passed to the command. |

**Non-block form** returns a three-element array:

| Element | Type | Description |
|---------|------|-------------|
| `reader` | `IO` | Readable IO (stdout + stderr merged). |
| `writer` | `IO` | Writable IO (stdin of the spawned process). |
| `pid` | `Integer` | Process ID of the spawned process. |

### `PTY.spawn(command, *args) { |reader, writer, pid| block }`

**Block form** yields `reader`, `writer`, and `pid` to the given block, and automatically closes the IOs after the block returns.

### `PTY.last_status -> Process::Status | nil`

Returns the exit status of the last spawned process.

- On platforms with native `PTY`, mirrors `$?`.
- On the fallback path, returns a `Process::Status` constructed from the exit code captured by the `node-pty` bridge.
- Returns `nil` if no process has been spawned yet or if the last spawn failed.

> [!TIP]
> Prefer `PTY.last_status` over `$?` for portable code that runs on both Windows and Unix.

## Documentation

- [RubyDoc](https://www.rubydoc.info/gems/pty_compat)

## How it works

1. `pty_compat` tries to load Ruby's standard `PTY` library first.
2. On `LoadError` (as raised on Windows), it prepends `PtyCompat::NodePty` into `PTY`.
3. `PtyCompat::NodePty` implements `PTY.spawn` through a Node.js bridge that uses `node-pty` to create a pseudo-terminal.
4. Stdout and stderr are merged into a single readable IO, matching the behaviour of Ruby's native `PTY.spawn`.

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────┐
│  Ruby code   │────▶│  PTY.spawn(...)  │────▶│  node-pty    │
│  (your app)  │     │  (patched)       │     │  bridge.js   │
└──────────────┘     └──────────────────┘     └──────┬───────┘
                                                     │
                                                     ▼
                                              ┌──────────────┐
                                              │  Command     │
                                              │  (shell,     │
                                              │   process)   │
                                              └──────────────┘
```

### `PTY.last_status`

On platforms with native `PTY`, `PTY.last_status` returns `$?` (`Process::Status`). On the fallback path, the bridge captures the exit code and exposes it through the same method. Prefer this over `$?` for portable code.

### Why not a pure Ruby PTY?

Alternative approaches rely on platform-specific C extensions that are painful to compile on Windows, or expose an incomplete `PTY` interface. `pty_compat` delegates the heavy lifting to [`node-pty`](https://github.com/microsoft/node-pty), a well-maintained native module by Microsoft that supports Windows, macOS, and Linux. This keeps the Ruby code small and the platform coverage broad.

## Development

```sh
bundle install
```

Run the tests:

```sh
bundle exec rspec
```

Lint with RuboCop:

```sh
bundle exec rubocop
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [Muriel-Salvan/pty_compat](https://github.com/Muriel-Salvan/pty_compat).

<a href="https://github.com/Muriel-Salvan/pty_compat/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Muriel-Salvan/pty_compat" />
</a>

## License

The gem is available as open source under the terms of the [BSD-3-Clause License](LICENSE).

---

<div align="center">

[![Star History Chart](https://api.star-history.com/svg?repos=Muriel-Salvan/pty_compat&type=Date)](https://star-history.com/#Muriel-Salvan/pty_compat&Date)

</div>
