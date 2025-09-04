# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-09-04

### Added
- Comprehensive variable validation for all numeric inputs
- Proper handling of external DLQ ARNs in outputs
- Initial CHANGELOG.md for release management

### Changed
- Improved output logic for dead_letter_queue_url to handle external DLQ ARNs
- Enhanced variable validation with AWS SQS service limits

### Fixed
- Fixed dead_letter_queue_url output when using external DLQ ARN
- Added missing validation rules for SQS configuration parameters

## [1.0.0] - 2025-09-04

### Added
- Initial release of AWS SQS Terraform module
- Standard SQS queue creation with configurable parameters
- Optional Dead Letter Queue (DLQ) creation or attachment via ARN
- SQS-managed server-side encryption support
- Secure queue policy denying non-SSL access
- Optional S3 -> SQS send permissions by account and/or bucket ARN
- Comprehensive tagging support
- Basic and advanced usage examples
- Complete justfile workflow for development and release management

### Security
- Implemented secure transport enforcement (SSL/TLS only)
- Added proper IAM policies for S3 integration
- Enabled server-side encryption options
