# shlex

[![Package Version](https://img.shields.io/hexpm/v/shlex)](https://hex.pm/packages/shlex)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/shlex/)

Split shell commands into words following [POSIX specification](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html).

```sh
gleam add shlex@1
```
```gleam
import shlex

pub fn main() -> Nil {
  let assert Ok(tokens) = shlex.split("git commit -m 'hello world!'")
  // ["git", "commit", "-m", "hello worlds!"]
}
```

Further documentation can be found at <https://hexdocs.pm/shlex>.

## Development

```sh
gleam test  # Run the tests
```

## Comparison with other shell lexers

The tokenizer follows the implementation of [rust-shlex](https://github.com/comex/rust-shlex), which is a simplified, POSIX-only version of Python [shlex](https://docs.python.org/3/library/shlex.html).