# Changelog

All notable changes to this project will be documented in this file.

Format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [v1.2.2] - 2025-07-27

### Added
- Output message for in-place encrypt / decrypt
- Tests for in-place mode of operation
- Additional tests for -c and -i

### Changed
- Restructure & rename test methods for clarity / maintainability

---

## [v1.2.1] - 2025-07-27

### Fixed
- Modified test_cases to clearly indicate that data is for testing purposes only

---

## [v1.2.0] - 2025-07-27

### Added
- Added `-v` flag to display version info
- Added test framework, test cases, test key & test results
- Added contributing guidelines

### Fixed
- Removed additional key file output when encrypting / decrypting to stdout because it breaks easy redirecting / piping

### Changed
- Update documentation

---

## [v1.1.0] - 2025-07-25

### Added
- Add ability to specify a custom key file path via `SCCRYPT_KEY_FILE` environment variable
- Changelog
- License

### Changed
- Improve usage info and error messages
- Update documentation

## [v1.0.0] - 2025-07-24

### Added
- Initial release of sccrypt
- File encryption and decryption functionality
- Support for in-place and copy modes
- Base64 encoding for encrypted output
- AES-256-CBC encryption with PBKDF2 key derivation 