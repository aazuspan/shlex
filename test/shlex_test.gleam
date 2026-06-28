import gleeunit
import shlex

pub fn main() -> Nil {
  gleeunit.main()
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
