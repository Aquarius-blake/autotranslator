Contributing to Auto Translate
Thank you for your interest in contributing to Auto Translate! We welcome contributions that improve the package, fix bugs, add features, or enhance documentation. Please follow these guidelines to ensure a smooth contribution process.
Table of Contents

Code of Conduct
Getting Started
Development Workflow
Coding Standards
Testing
Pull Requests
Commit Messages
Documentation
Releasing


Code of Conduct
This project follows the Flutter Contributor Code of Conduct. By participating, you agree to uphold these standards.

Getting Started
Prerequisites

Flutter SDK (≥3.0.0)
Dart SDK (≥2.17.0)
Git
VS Code or Android Studio with Flutter/Dart extensions

Setup

Fork the Repository

Fork autotranslator on GitHub


Clone Your Fork
git clone https://github.com/YOUR_USERNAME/autotranslator.git
cd autotranslator


Add Upstream Remote
git remote add upstream https://github.com/yourusername/autotranslator.git


Install Dependencies
flutter pub get


Generate Mocks (for tests)
flutter pub run build_runner build


Run Tests
flutter test


Run Example App
cd example
flutter run



Repository Structure
autotranslator/
├── lib/                # Public API (autotranslator_widget.dart)
├── lib/src             # Code
├── test/               # Unit tests
├── example/            # Example app
├── .github/            # Workflows, issue templates
├── docs/               # Additional documentation
├── pubspec.yaml        # Package configuration
└── README.md           # Main documentation


Development Workflow

Create Feature Branch
git checkout -b feature/add-language-support


Make Changes

Follow Coding Standards
Add tests for new features
Update documentation


Test Locally
flutter test
cd example && flutter run


Commit Changes
git add .
git commit -m "feat: add support for 10 new languages"


Push Branch
git push origin feature/add-language-support


Open Pull Request (see Pull Requests)



Coding Standards
Dart Style Guide
Follow the Effective Dart guidelines:



Rule
✅ Do
❌ Don't



Naming
snake_case for variables/functions
camelCase


Classes
PascalCase
snake_case


Constants
kConstantName
CONSTANT_NAME


Lines
≤80 characters
>100 characters


Imports
dart:, package:, relative order
Mixed order


Flutter-Specific

Use const constructors everywhere possible
Prefer StatelessWidget over StatefulWidget

Package-Specific



Component
Guidelines



Public API
Only expose in lib/autotranslator.dart


Private
Prefix with _ (e.g., _offlineTranslations)


Translations
Add to _offlineTranslations with all supported languages



Providers
Extend ChangeNotifier, call notifyListeners()


Example:
/// Public API - GOOD
class AutoTranslateText extends StatelessWidget {
  const AutoTranslateText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Selector<LanguageProvider, String>(
      selector: (_, provider) => provider.selectedLanguage,
      builder: (context, language, _) => Text(text), // Simplified
    );
  }
}

// Private helper - GOOD
const Map<String, String> _getTranslation(String key, String lang) => {...};


Testing
All major contributions require tests! Aim for 100% coverage.
Unit Tests

Located in test/autotranslator_test.dart
Use mockito for dependency mocking
Test both online and offline scenarios

Example:
test('translateText returns offline translation when offline', () async {
  when(mockConnectivity.checkConnectivity())
      .thenAnswer((_) async => [ConnectivityResult.none]);
  final result = await languageProvider.translateText('Hello', 'es');
  expect(result, 'Hola');
});

Widget Tests (Optional)
Add to test/ for UI validation:
flutter test test/widget_test.dart

Running Tests



Command
Description



flutter test
Run all tests


flutter test --coverage
Generate coverage report


flutter test test/auto_translate_test.dart
Run specific file


Coverage Requirement: ≥95% for new code.

Pull Requests
Requirements Checklist

 Tests pass (flutter test)
 Example app works (cd example && flutter run)
 Code follows Dart Style Guide
 Documentation updated
 CHANGELOG.md entry added
 No breaking changes (or documented)

PR Template
All PRs use this template (auto-filled from .github/pull_request_template.md):
## Description

Brief description of changes

## Related Issue

Closes #123

## Checklist

- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Example app verified
- [ ] CHANGELOG entry added

## Testing

| Test | Result |
|------|--------|
| `flutter test` | ✅ PASS |
| Example app | ✅ WORKS |

## Screenshots (if UI changes)

Before | After
---|---
![before](screenshots/before.png) | ![after](screenshots/after.png)

Review Process



Status
Time
Action



Draft
-
Work in progress


Ready
24h
Automated checks run


Approved
≥48h
Merge to main


Conflict
-
Rebase required


Merge Requirements:

✅ All checks pass
✅ ≥1 approval (maintainer)
✅ No conflicts


Commit Messages
Follow Conventional Commits:



Type
Examples
When to Use



feat
feat: add Italian language support
New feature


fix
fix: resolve FutureBuilder timeout issue
Bug fix


docs
docs: update offline translation guide
Documentation


test
test: add coverage for offline fallback
Tests


refactor
refactor: optimize Selector usage
Code changes


chore
chore: update dependencies
Maintenance


Format:
<type>[optional scope]: <description>

[optional body]

[optional footer]

Example:
feat(translations): add Portuguese and Italian support

Added 2 new languages to _offlineTranslations map
Updated example app dropdown

Closes #45


Documentation
README.md

Update Usage section for new features
Add screenshots for UI changes
Update Installation

Dart Documentation
Add /// comments to all public APIs:
/// Translates text to the selected language, with online/offline fallback.
Future<String> translateText(String text, String toLanguage)

CHANGELOG.md
Add entries for all changes:
## [0.2.0] - 2025-01-15
### Added
- Support for Portuguese (`pt`) and Italian (`it`)
- Widget tests for AutoTranslateText

### Fixed
- Timeout handling for slow networks


Releasing
Maintainers only. Follow semantic versioning:



Version
When
Example



MAJOR
Breaking changes
1.0.0


MINOR
New features
0.2.0


PATCH
Bug fixes
0.1.1


Release Steps

Update Version
# In pubspec.yaml
version: 0.2.0+1


Update CHANGELOG.md

Tag Release
git tag v0.2.0
git push origin v0.2.0


Publish
flutter pub publish


Create GitHub Release

Use CHANGELOG content
Attach example APK




Good First Issues
Look for issues labeled:

good first issue
help wanted
beginner

See current issues

Questions?

Bug: Open Issue
Feature: Open Issue
Question: Discussions
Support: Flutter Discord


Acknowledgements
Thank you to all contributors! 🎉
Last Updated: October 15, 2025
Template based on Flutter Contributing Guide
