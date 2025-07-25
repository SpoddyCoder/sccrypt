# Changelog

All notable changes to this project will be documented in this file.

Format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [1.1.0] - 2025-07-25

### Added
- Add ability to specify a custom key file path via `SCCRYPT_KEY_FILE` environment variable
- Changelog
- License

### Changed
- Improve usage info and error messages
- Update documentation

## [1.0.0] - 2025-07-24

### Added
- Initial release of sccrypt
- File encryption and decryption functionality
- Support for in-place and copy modes
- Base64 encoding for encrypted output
- AES-256-CBC encryption with PBKDF2 key derivation 