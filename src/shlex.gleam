import gleam/bool
import gleam/list
import gleam/set
import gleam/string

// A list of single graphemes split from a string input
type Graphemes =
  List(String)

// A list of complete, lexed token
type Tokens =
  List(String)

// A working buffer that will be assembled into a token 
type Buffer =
  List(String)

/// An error that occurs when lexing a shell input
pub type LexError {
  /// A quote was opened without a matching closing quote
  UnclosedQuotation
  /// An escape was encountered without a following character to escape
  NoEscapedCharacter
}

/// Split a shell input into a list of string tokens.
/// 
/// This aims to follow the POSIX standard defined by IEEE Std 1003.1-2024.
/// 
/// ## Examples
/// 
/// ```gleam
/// let assert Ok(tokens) = shlex.split("git commit -m 'hello world!'")
/// assert tokens == ["git", "commit", "-m", "hello world!"]
/// ```
pub fn split(input: String) -> Result(Tokens, LexError) {
  input |> string.to_graphemes |> continue([])
}

/// Concatenate a list of string inputs into an escaped shell command.
/// 
/// This is a convenience function that applies ``shlex.quote`` to each element
/// and joins the result. It is the inverse of ``shlex.split``. 
/// 
/// __Warning__: See ``shlex.quote`` for potential vulnerabilities in
/// non-POSIX and interactive shells.
/// 
/// ## Examples
/// ```gleam
/// let unsafe_input = "foo; cat ~/.ssh/id_rsa"
/// assert shlex.join(["git", "commit", "-m", unsafe_input])
///   == "git commit -m 'foo; cat ~/.ssh/id_rsa'"
/// ```
pub fn join(input: List(String)) -> String {
  input |> list.map(quote) |> string.join(" ")
}

/// Escape a string input into a shell word.
/// 
/// __Warning__: The output is safe for POSIX shell parsing, but may be 
/// vulnerable to shell injection in non-POSIX-compliant shells or interactive 
/// shells with history expansion, quick substitution, or other parsing 
/// extensions.
/// 
/// ## Examples
/// 
/// ```gleam
/// let unsafe_input = "foo; cat ~/.ssh/id_rsa"
/// assert shlex.quote(unsafe_input) == "'foo; cat ~/.ssh/id_rsa'"
/// ```
pub fn quote(input: String) -> String {
  let safe =
    "%+,-./0123456789:=@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz"
    |> string.to_graphemes
    |> set.from_list
  let unsafe_inputs =
    input
    |> string.to_graphemes
    |> set.from_list
    |> set.difference(safe)

  use <- bool.guard(string.is_empty(input), "''")
  use <- bool.guard(set.is_empty(unsafe_inputs), input)
  "'" <> string.replace(input, "'", "'\"'\"'") <> "'"
}

fn continue(input: Graphemes, acc: Tokens) -> Result(Tokens, LexError) {
  case input {
    [] -> acc |> list.reverse |> Ok

    // Skip whitespace between words
    [" ", ..rest] | ["\t", ..rest] | ["\n", ..rest] -> continue(rest, acc)

    // Consume comment lines
    ["#", ..rest] -> comment(rest, acc)

    _ -> word(input, acc, [])
  }
}

fn comment(input: Graphemes, acc: Tokens) -> Result(Tokens, LexError) {
  case input {
    [] -> continue([], acc)

    // Comment is ended by newline
    ["\n", ..rest] -> continue(rest, acc)

    [_, ..rest] -> comment(rest, acc)
  }
}

fn word(
  input: Graphemes,
  acc: Tokens,
  buf: Buffer,
) -> Result(Tokens, LexError) {
  case input {
    [] -> continue([], push_buffer(buf, acc))

    // <backslash> at EOF has nothing to escape
    ["\\"] -> Error(NoEscapedCharacter)

    // <newline> immediately following <backslash> is a line continuation
    ["\\", "\n", ..rest] -> word(rest, acc, buf)

    // Any other <backslash> preserves the literal
    ["\\", next, ..rest] -> word(rest, acc, [next, ..buf])

    // Begin a quoted token
    ["'", ..rest] -> single_quote(rest, acc, buf)
    ["\"", ..rest] -> double_quote(rest, acc, buf)

    // Word ended by un-escaped whitespace
    [" ", ..rest] | ["\t", ..rest] | ["\n", ..rest] ->
      continue(rest, push_buffer(buf, acc))

    [hd, ..rest] -> word(rest, acc, [hd, ..buf])
  }
}

fn single_quote(
  input: Graphemes,
  acc: Tokens,
  buf: Buffer,
) -> Result(Tokens, LexError) {
  case input {
    [] -> Error(UnclosedQuotation)

    // Ended by single-quote
    ["'", ..rest] -> word(rest, acc, buf)

    // Treat everything else as a literal
    [hd, ..rest] -> single_quote(rest, acc, [hd, ..buf])
  }
}

fn double_quote(
  input: Graphemes,
  acc: Tokens,
  buf: Buffer,
) -> Result(Tokens, LexError) {
  case input {
    [] -> Error(UnclosedQuotation)

    // Special-case escaped characters
    ["\\", c, ..rest] -> {
      case c {
        // Consume newlines
        "\n" -> double_quote(rest, acc, buf)
        // Escape only a subset of characters, e.g. \$ -> $
        "$" | "`" | "\"" | "\\" -> double_quote(rest, acc, [c, ..buf])
        // Treat everything else as literals, e.g. \t -> \t 
        _ -> double_quote(rest, acc, ["\\" <> c, ..buf])
      }
    }

    // Ended by double-quote. This must match AFTER the escaped form \" 
    ["\"", ..rest] -> word(rest, acc, buf)

    [hd, ..rest] -> double_quote(rest, acc, [hd, ..buf])
  }
}

/// Merge the character buffer into a token and push it onto the accumulator
fn push_buffer(buf: Buffer, acc: Tokens) -> Tokens {
  case buf {
    [] -> acc
    _ -> [buf |> list.reverse |> string.join(""), ..acc]
  }
}
