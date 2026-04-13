# Testing Strategy

## Principles

- Any failing tests must be captured as new test cases, whether they come from compilation, user feedback, or unexpected behavior.
- Tests must be kept in sync with functional code.
- Do not keep tests that are no longer relevant
- Focus on common paths first
- Treat offline-only operation as a core product requirement and verify implemented features still work without network connectivity.
- Add explicit tests for edge cases that are universal across all kinds of apps:
  - Repeated events
  - Unparseable inputs
  - Unexpected delays
  - App termination
  - Data values not expected
- Consider property testing for core code logic
