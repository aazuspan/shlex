# shlex

[![Package Version](https://img.shields.io/hexpm/v/shlex)](https://hex.pm/packages/shlex)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/shlex/)

Split shell commands into words or join words into escaped commands. It's [Python shlex](https://docs.python.org/3/library/shlex.html)*, for Gleam.

```sh
gleam add shlex@1
```
```gleam
import shlex

pub fn main() {
  shlex.split("git commit -m 'hello world!'") |> echo
  // Ok(["git", "commit", "-m", "hello world!"])

  shlex.join(["git", "commit", "-m", "hello world!"]) |> echo
  // "git commit -m 'hello world!'"

  shlex.quote(";cat /etc/passwd") |> echo
  // "';cat /etc/passwd'"
}
```

Further documentation can be found at <https://hexdocs.pm/shlex>.


## Limitations

Like the [Python shlex](https://docs.python.org/3/library/shlex.html) library, quoting only ensures safety in POSIX-compliant, non-interactive shells. Quoted outputs could still be vulnerable to shell injection if you paste them into a shell with interactive features like history expansion and quick substitution.

## Development

```sh
gleam test  # Run the tests
```

*`shlex.split` matches Python's `posix=True` mode, so it's more like [rust-shlex](https://github.com/comex/rust-shlex).