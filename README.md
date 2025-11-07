<!-- GitAds-Verify: NAYM8W7JKRYXG3KN25TXXA4NBMN9SLC6 -->
## GitAds Sponsored
[![Sponsored by GitAds](https://gitads.dev/v1/ad-serve?source=aquarius-blake/autotranslator@github)](https://gitads.dev/v1/ad-track?source=aquarius-blake/autotranslator@github)


# Auto Translate

A Flutter package for automatic text translation in your app, supporting both online and offline modes. It uses the `translator` package for online translations via Google Translate API and a static key-value map for offline translations. The package integrates with `provider` for state management and `connectivity_plus` to detect network status.

## Features

- **Dynamic Language Switching**: Change the app's language at runtime with automatic UI updates.
- **Online Translation**: Uses Google Translate API for real-time translations when online.
- **Offline Translation**: Fallback to pre-defined translations when offline.
- **Robust Error Handling**: Handles network issues, API errors, and timeouts gracefully.
- **Easy Integration**: Simple widget (`AutoTranslateText`) to wrap text for translation.

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  auto_translate: ^0.1.0
  provider: ^6.1.5+1
  translator: ^1.0.4+1
  connectivity_plus: ^7.0.0
```

Run `flutter pub get` to install the dependencies.

## Usage

### 1. Set Up the Provider

Wrap your app with `ChangeNotifierProvider` to provide the `LanguageProvider`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_translate/auto_translate.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}
```

### 2. Use `AutoTranslateText` Widget

Wrap any text you want to translate with `AutoTranslateText`:

```dart
import 'package:auto_translate/auto_translate.dart';

AutoTranslateText(
  text: 'Welcome to my application!',
  style: TextStyle(fontSize: 20),
)
```

### 3. Switch Languages

Use `LanguageProvider` to change the language:

```dart
Consumer<LanguageProvider>(
  builder: (context, languageProvider, _) => DropdownButton<String>(
    value: languageProvider.selectedLanguage,
    items: const [
      DropdownMenuItem(value: 'en', child: Text('English')),
      DropdownMenuItem(value: 'es', child: Text('Spanish')),
      DropdownMenuItem(value: 'fr', child: Text('French')),
      DropdownMenuItem(value: 'de', child: Text('German')),
    ],
    onChanged: (value) {
      if (value != null) {
        languageProvider.setLanguage(value);
      }
    },
  ),
)
```

### 4. Add Offline Translations

Update the `_offlineTranslations` map in `lib/src/auto_translate.dart` to include your app's text strings:

```dart
const Map<String, Map<String, String>> _offlineTranslations = {
  'en': {
    'Your custom text': 'Your custom text',
  },
  'es': {
    'Your custom text': 'Tu texto personalizado',
  },
};
```

### Example App

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_translate/auto_translate.dart';

void main() {
  runApp(const AutoTranslateApp());
}

class AutoTranslateApp extends StatelessWidget {
  const AutoTranslateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const AutoTranslateText(text: 'My App'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Consumer<LanguageProvider>(
                  builder: (context, languageProvider, _) => Column(
                    children: [
                      DropdownButton<String>(
                        value: languageProvider.selectedLanguage,
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'es', child: Text('Spanish')),
                          DropdownMenuItem(value: 'fr', child: Text('French')),
                          DropdownMenuItem(value: 'de', child: Text('German')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            languageProvider.setLanguage(value);
                          }
                        },
                      ),
                      Text(
                        languageProvider.isOnline ? 'Online Mode' : 'Offline Mode',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const AutoTranslateText(
                  text: 'Welcome to my application!',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                const AutoTranslateText(
                  text: 'This is a sample text to demonstrate translation.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## Configuration

- **Online Translations**: Requires an internet connection. The `translator` package uses Google Translate API. Check its documentation for any API key requirements.
- **Offline Translations**: Add your text strings to `_offlineTranslations` in `lib/auto_translate.dart`.
- **Timeouts**: The package includes a 10-second timeout for connectivity checks and online translations to prevent hanging.

## Debugging

Run your app with `flutter run --debug` to see logs indicating:

- Language changes (`Setting language to: ...`)
- Connectivity status (`Connectivity status: Online/Offline`)
- Translation results (`Online translation result: ...` or `Using offline translation: ...`)
- Errors (`Online translation error: ...`)

## Contributing

Contributions are welcome! Please:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -m 'Add your feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

## License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
