# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/2.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- `shlex.split` no longer incorrectly erases empty strings. For example, `shlex.split("''")` returns `Ok([""])` instead of `Ok([])`.

## [1.1.0] - 2026-07-03

### Added

- `shlex.quote` and `shlex.join`

## [1.0.0] - 2026-06-28

### Added

- `shlex.split`

[unreleased]: https://github.com/aazuspan/shlex/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/aazuspan/shlex/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/aazuspan/shlex/releases/tag/v1.0.0
