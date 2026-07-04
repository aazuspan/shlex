import gleam/list
import gleam/string
import gleeunit
import shlex

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn quote_wraps_empty_input_test() {
  assert shlex.quote("") == "''"
}

pub fn quote_leaves_safe_string_unquoted_test() {
  let safe =
    "%+,-./0123456789:=@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz"
  assert shlex.quote(safe) == safe
}

pub fn quote_wraps_string_with_spaces_test() {
  assert shlex.quote("foo bar") == "'foo bar'"
}

pub fn quote_leaves_safe_punctuation_unquoted_test() {
  assert shlex.quote("AZaz09_./-+=:@%") == "AZaz09_./-+=:@%"
}

pub fn quote_wraps_shell_metacharacters_test() {
  assert shlex.quote("foo; rm -rf /") == "'foo; rm -rf /'"
}

pub fn quote_escapes_embedded_single_quotes_test() {
  assert shlex.quote("foo'bar") == "'foo'\"'\"'bar'"
}

pub fn quote_round_trips_unsafe_input_as_single_token_test() {
  let unsafe_input = "$(touch /tmp/oops); echo hacked"

  assert shlex.split(shlex.quote(unsafe_input)) == Ok([unsafe_input])
}

pub fn quote_round_trips_embedded_single_quotes_as_single_token_test() {
  let unsafe_input = "it's; $(still unsafe)"

  assert shlex.split(shlex.quote(unsafe_input)) == Ok([unsafe_input])
}

pub fn join_quotes_each_argument_and_separates_with_spaces_test() {
  assert shlex.join(["echo", "foo bar", "it's"])
    == "echo 'foo bar' 'it'\"'\"'s'"
}

pub fn join_round_trips_multiple_unsafe_arguments_test() {
  let args = ["echo", "$(touch /tmp/oops)", "semi;colon", "it's ok"]

  assert shlex.split(shlex.join(args)) == Ok(args)
}

pub fn split_keeps_plain_dollar_signs_test() {
  assert shlex.split("foo$baz") == Ok(["foo$baz"])
}

pub fn split_separates_words_on_whitespace_test() {
  assert shlex.split("foo baz") == Ok(["foo", "baz"])
}

pub fn split_concatenates_double_quoted_segments_with_word_text_test() {
  assert shlex.split("foo\"bar\"baz") == Ok(["foobarbaz"])
}

pub fn split_keeps_adjacent_double_quoted_text_in_same_word_test() {
  assert shlex.split("foo \"bar\"baz") == Ok(["foo", "barbaz"])
}

pub fn split_skips_leading_spaces_and_newlines_between_words_test() {
  assert shlex.split("   foo \nbar") == Ok(["foo", "bar"])
}

pub fn split_treats_backslash_newline_as_line_continuation_test() {
  assert shlex.split("foo\\\nbar") == Ok(["foobar"])
}

pub fn split_treats_backslash_newline_as_line_continuation_in_double_quotes_test() {
  assert shlex.split("\"foo\\\nbar\"") == Ok(["foobar"])
}

pub fn split_treats_backslashes_as_literals_in_single_quotes_test() {
  assert shlex.split("'baz\\$b'") == Ok(["baz\\$b"])
}

pub fn split_errors_on_unclosed_single_quote_after_literal_backslash_test() {
  assert shlex.split("'baz\\''") == Error(shlex.UnclosedQuotation)
}

pub fn split_errors_on_trailing_backslash_at_top_level_test() {
  assert shlex.split("\\") == Error(shlex.NoEscapedCharacter)
}

pub fn split_errors_on_unclosed_double_quote_after_trailing_backslash_test() {
  assert shlex.split("\"\\") == Error(shlex.UnclosedQuotation)
}

pub fn split_errors_on_unclosed_single_quote_after_trailing_backslash_test() {
  assert shlex.split("'\\") == Error(shlex.UnclosedQuotation)
}

pub fn split_errors_on_lonely_double_quote_test() {
  assert shlex.split("\"") == Error(shlex.UnclosedQuotation)
}

pub fn split_errors_on_lonely_single_quote_test() {
  assert shlex.split("'") == Error(shlex.UnclosedQuotation)
}

pub fn split_ignores_inline_comments_until_newline_test() {
  assert shlex.split("foo #bar\nbaz") == Ok(["foo", "baz"])
}

pub fn split_treats_hash_without_leading_whitespace_as_literal_test() {
  assert shlex.split("foo#bar") == Ok(["foo#bar"])
}

pub fn split_errors_when_double_quote_starts_before_comment_marker_test() {
  assert shlex.split("foo\"#bar") == Error(shlex.UnclosedQuotation)
}

pub fn split_keeps_backslash_n_literal_in_single_quotes_test() {
  assert shlex.split("'\\n'") == Ok(["\\n"])
}

pub fn split_keeps_double_backslash_n_literal_in_single_quotes_test() {
  assert shlex.split("'\\\\n'") == Ok(["\\\\n"])
}

pub fn split_keeps_single_quoted_text_inside_word_boundaries_test() {
  assert shlex.split("foo'bar'baz") == Ok(["foobarbaz"])
}

pub fn split_allows_single_quoted_prefix_and_suffix_without_breaking_word_test() {
  assert shlex.split("'foo'bar'baz'") == Ok(["foobarbaz"])
}

pub fn split_allows_mixed_single_and_double_quoted_segments_in_one_word_test() {
  assert shlex.split("foo'bar'\"baz\"") == Ok(["foobarbaz"])
}

pub fn split_escapes_space_outside_quotes_test() {
  assert shlex.split("foo\\ bar") == Ok(["foo bar"])
}

pub fn split_escapes_hash_outside_quotes_test() {
  assert shlex.split("foo\\#bar") == Ok(["foo#bar"])
}

pub fn split_escapes_backslash_outside_quotes_test() {
  assert shlex.split("foo\\\\bar") == Ok(["foo\\bar"])
}

pub fn split_escapes_non_special_characters_outside_quotes_test() {
  assert shlex.split("foo\\xbar") == Ok(["fooxbar"])
}

pub fn split_escapes_t_outside_quotes_test() {
  assert shlex.split("foo\\tbar") == Ok(["footbar"])
}

pub fn split_unescapes_dollar_inside_double_quotes_test() {
  assert shlex.split("\"foo\\$bar\"") == Ok(["foo$bar"])
}

pub fn split_unescapes_backtick_inside_double_quotes_test() {
  assert shlex.split("\"foo\\`bar\"") == Ok(["foo`bar"])
}

pub fn split_unescapes_backslash_inside_double_quotes_test() {
  assert shlex.split("\"foo\\\\bar\"") == Ok(["foo\\bar"])
}

pub fn split_preserves_backslash_before_non_special_characters_in_double_quotes_test() {
  assert shlex.split("\"foo\\xbar\"") == Ok(["foo\\xbar"])
}

pub fn split_preserves_backslash_before_t_in_double_quotes_test() {
  assert shlex.split("\"foo\\tbar\"") == Ok(["foo\\tbar"])
}

pub fn split_returns_empty_list_for_empty_input_test() {
  assert shlex.split("") == Ok([])
}

pub fn split_returns_empty_list_for_spaces_only_input_test() {
  assert shlex.split("   ") == Ok([])
}

pub fn split_returns_empty_list_for_mixed_whitespace_only_input_test() {
  assert shlex.split("\t\n  ") == Ok([])
}

pub fn split_errors_on_trailing_backslash_after_word_test() {
  assert shlex.split("foo\\") == Error(shlex.NoEscapedCharacter)
}

pub fn split_errors_on_trailing_backslash_at_end_of_double_quoted_word_test() {
  assert shlex.split("\"foo\\\"") == Error(shlex.UnclosedQuotation)
}

pub fn split_discards_comment_only_input_test() {
  assert shlex.split("# comment only") == Ok([])
}

pub fn split_ignores_comment_only_lines_between_tokens_test() {
  assert shlex.split("foo\n# comment on new line\nbaz") == Ok(["foo", "baz"])
}

pub fn split_ignores_comment_until_end_of_input_test() {
  assert shlex.split("foo # comment ends at EOF") == Ok(["foo"])
}

pub fn quote_matches_python_test() {
  // Ported from Python's shlex tests
  let unicode_sample = "éàß"
  let unsafe = "\"`$\\!" <> unicode_sample
  unsafe
  |> string.to_graphemes
  |> list.each(fn(u) {
    assert shlex.quote("test" <> u <> "name") == "'test" <> u <> "name'"

    assert shlex.quote("test" <> u <> "'name'")
      == "'test" <> u <> "'\"'\"'name'\"'\"''"
  })
}

pub fn split_matches_python_test() {
  get_test_cases()
  |> list.each(fn(test_case) {
    assert shlex.split(test_case.0) == Ok(test_case.1)
      as { "Split failed with input " <> test_case.0 }
  })
}

pub fn join_matches_python_test() {
  let test_cases = [
    #(["a ", "b"], "'a ' b"),
    #(["a", " b"], "a ' b'"),
    #(["a", " ", "b"], "a ' ' b"),
    #(["\"a", "b\""], "'\"a' 'b\"'"),
  ]

  test_cases
  |> list.each(fn(test_case) {
    assert shlex.join(test_case.0) == test_case.1
  })
}

pub fn join_roundtrip_test() {
  get_test_cases()
  |> list.each(fn(test_case) {
    let joined = shlex.join(test_case.1)
    let resplit = shlex.split(joined)
    assert resplit == Ok(test_case.1)
  })
}

/// Recreated from Python's shlex test cases, which were originally from 
/// shellwords by Hartmut Goebel.
fn get_test_cases() -> List(#(String, List(String))) {
  [
    #("x", ["x"]),
    #("foo bar", ["foo", "bar"]),
    #(" foo bar", ["foo", "bar"]),
    #(" foo bar ", ["foo", "bar"]),
    #("foo   bar    bla     fasel", ["foo", "bar", "bla", "fasel"]),
    #("x y  z              xxxx", ["x", "y", "z", "xxxx"]),
    #("\\x bar", ["x", "bar"]),
    #("\\ x bar", [" x", "bar"]),
    #("\\ bar", [" bar"]),
    #("foo \\x bar", ["foo", "x", "bar"]),
    #("foo \\ x bar", ["foo", " x", "bar"]),
    #("foo \\ bar", ["foo", " bar"]),
    #("foo \"bar\" bla", ["foo", "bar", "bla"]),
    #("\"foo\" \"bar\" \"bla\"", ["foo", "bar", "bla"]),
    #("\"foo\" bar \"bla\"", ["foo", "bar", "bla"]),
    #("\"foo\" bar bla", ["foo", "bar", "bla"]),
    #("foo 'bar' bla", ["foo", "bar", "bla"]),
    #("'foo' 'bar' 'bla'", ["foo", "bar", "bla"]),
    #("'foo' bar 'bla'", ["foo", "bar", "bla"]),
    #("'foo' bar bla", ["foo", "bar", "bla"]),
    #("blurb foo\"bar\"bar\"fasel\" baz", ["blurb", "foobarbarfasel", "baz"]),
    #("blurb foo'bar'bar'fasel' baz", ["blurb", "foobarbarfasel", "baz"]),
    #("\"\"", [""]),
    #("''", [""]),
    #("foo \"\" bar", ["foo", "", "bar"]),
    #("foo '' bar", ["foo", "", "bar"]),
    #("foo \"\" \"\" \"\" bar", ["foo", "", "", "", "bar"]),
    #("foo '' '' '' bar", ["foo", "", "", "", "bar"]),
    #("\\\"", ["\""]),
    #("\"\\\"\"", ["\""]),
    #("\"foo\\ bar\"", ["foo\\ bar"]),
    #("\"foo\\\\ bar\"", ["foo\\ bar"]),
    #("\"foo\\\\ bar\\\"\"", ["foo\\ bar\""]),
    #("\"foo\\\\\" bar\\\"", ["foo\\", "bar\""]),
    #("\"foo\\\\ bar\\\" dfadf\"", ["foo\\ bar\" dfadf"]),
    #("\"foo\\\\\\ bar\\\" dfadf\"", ["foo\\\\ bar\" dfadf"]),
    #("\"foo\\\\\\x bar\\\" dfadf\"", ["foo\\\\x bar\" dfadf"]),
    #("\"foo\\x bar\\\" dfadf\"", ["foo\\x bar\" dfadf"]),
    #("\\'", ["'"]),
    #("'foo\\ bar'", ["foo\\ bar"]),
    #("'foo\\\\ bar'", ["foo\\\\ bar"]),
    #("\"foo\\\\\\x bar\\\" df'a\\ 'df\"", ["foo\\\\x bar\" df'a\\ 'df"]),
    #("\\\"foo", ["\"foo"]),
    #("\\\"foo\\x", ["\"foox"]),
    #("\"foo\\x\"", ["foo\\x"]),
    #("\"foo\\ \"", ["foo\\ "]),
    #("foo\\ xx", ["foo xx"]),
    #("foo\\ x\\x", ["foo xx"]),
    #("foo\\ x\\x\\\"", ["foo xx\""]),
    #("\"foo\\ x\\x\"", ["foo\\ x\\x"]),
    #("\"foo\\ x\\x\\\\\"", ["foo\\ x\\x\\"]),
    #("\"foo\\ x\\x\\\\\"\"foobar\"", ["foo\\ x\\x\\foobar"]),
    #("\"foo\\ x\\x\\\\\"\\'\"foobar\"", ["foo\\ x\\x\\'foobar"]),
    #("\"foo\\ x\\x\\\\\"\\'\"fo'obar\"", ["foo\\ x\\x\\'fo'obar"]),
    #("\"foo\\ x\\x\\\\\"\\'\"fo'obar\" 'don'\\''t'", [
      "foo\\ x\\x\\'fo'obar",
      "don't",
    ]),
    #("\"foo\\ x\\x\\\\\"\\'\"fo'obar\" 'don'\\''t' \\\\", [
      "foo\\ x\\x\\'fo'obar",
      "don't",
      "\\",
    ]),
    #("'foo\\ bar'", ["foo\\ bar"]),
    #("'foo\\\\ bar'", ["foo\\\\ bar"]),
    #("foo\\ bar", ["foo bar"]),
    // Modified to match the default ``comments=False`` behavior
    #("foo#bar\nbaz", ["foo#bar", "baz"]),
    #(":-) ;-)", [":-)", ";-)"]),
    #("áéíóú", ["áéíóú"]),
  ]
}
