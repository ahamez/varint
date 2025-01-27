# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.1]

### Changed
- Unroll decoding. Benchmarks show a factor going from ~1.5x faster for values encoded on 2 bytes to ~1.8x faster for values encoded on 8 bytes.

## [1.5]

### Changed
- Unroll encoding. Benchmarks show a factor going from ~3x faster for values encoded on 2 bytes to ~9x faster for values encoded on 8 bytes.

## [1.4]

### Changed
- Fix warning of deprecated `require Bitwise`

## [1.3]

### Changed
- More documentation

## [1.2]

### Added
- Raise exception when an error happens while decoding

## [1.1]

### Changed
- BREAKING CHANGE: `decode/1` returns the decode value as well as the rest of the binary

## [1.0]
- Initial version
