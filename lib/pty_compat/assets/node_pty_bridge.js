// This NodeJS bridge is used only on platforms that don't support Ruby's PTY standard library.
// This is needed to use the CLIs from Ruby on Windows.
// This bridge will use the node-pty module of NodeJS to bridge a command line through a PTY interface.
// To use it the user must first install the node-pty module in the project that will be using the pty_compat Rubygem, like this:
// npm install node-pty

const pty = require("node-pty");

const [cmd, ...args] = process.argv.slice(2);

const shell = pty.spawn(cmd, args, {
  name: "xterm-color",
  cols: 80,
  rows: 30,
  cwd: process.cwd(),
  env: process.env
});

// Send output to Ruby
shell.on("data", (data) => {
  process.stdout.write(data);
});

// Read commands from Ruby (stdin)
process.stdin.setEncoding("utf8");

process.stdin.on("data", (data) => {
  shell.write(data);
});

// Catch the exit properly
shell.on("exit", (code, signal) => {
  process.exit(code ?? 0);
});
