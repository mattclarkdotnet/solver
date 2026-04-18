# Testing Strategy

## Principles

- Any failing tests must be captured as new test cases, whether they come from compilation, user feedback, or unexpected behavior.
- Tests must be kept in sync with functional code.
- Do not keep tests that are no longer relevant
- Focus on common paths first
- Treat offline-only operation as a core product requirement and verify implemented features still work without network connectivity.
- Treat bundled word-list and lookup-list record formats as part of the product contract, and add or update tests when those formats change.
- Treat the shared bundled test vocabulary as part of the product contract for the current seed data, and add or update tests when one implemented tool's test list diverges from the others.
- Treat the `Resources/wordlists/test/` layout as part of the current packaging contract, while still verifying loaders cope with the app bundle structure Xcode actually emits.
- Treat bundled word-list-group selection as a product contract: tests should cover the persisted in-app preference, switching groups without leaving the current tool, and continued offline loading from the selected group.
- Treat live-search cancellation as a product contract: tests should cover superseded queries being cancelled, only the latest query publishing state, and word-list changes not reviving stale results.
- Treat the bottom status bar as a product contract: tests should cover the visible active word list, in-place switching from the bottom bar, and secondary `Preferences`, `Help`, and `About` actions that preserve the active tool.
- Add explicit tests for edge cases that are universal across all kinds of apps:
  - Repeated events
  - Unparseable inputs
  - Unexpected delays
  - App termination
  - Data values not expected
- Consider property testing for core code logic
