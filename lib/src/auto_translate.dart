import 'dart:async';

import 'package:autotranslator_widget/src/Translations.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Offline translation data
const Map<String, Map<String, String>> _offlineTranslations = offlineTranslations;

// Language provider to manage the selected language and translation mode
class LanguageProvider with ChangeNotifier {
  String _selectedLanguage = 'en'; // Default language is English
  final GoogleTranslator translator;
  final Connectivity connectivity; 
  bool _isOnline = true;

  String get selectedLanguage => _selectedLanguage;
  bool get isOnline => _isOnline;

  LanguageProvider({GoogleTranslator? translator, Connectivity? connectivity})
      : translator = translator ?? GoogleTranslator(),
        connectivity = connectivity ?? Connectivity() {
    _checkConnectivity();
  }

  void setLanguage(String languageCode) {
    print('Setting language to: $languageCode');
    _selectedLanguage = languageCode;
    notifyListeners();
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResults = await connectivity.checkConnectivity().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Connectivity check timed out, assuming offline');
          return [ConnectivityResult.none];
        },
      );
      _isOnline = connectivityResults.any((result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet);
      print('Connectivity status: ${_isOnline ? 'Online' : 'Offline'}');
      notifyListeners();
      return;
    } catch (e) {
      print('Connectivity check error: $e');
      _isOnline = false;
      notifyListeners();
      return;
    }
  }

  Future<String> translateText(String text, String toLanguage) async {
    debugPrint('Translating text: "$text" to language: $toLanguage');
    await _checkConnectivity();
    
    if (_isOnline) {
      try {
        final translation = await translator.translate(text, to: toLanguage).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('Online translation timed out for: "$text"');
            throw TimeoutException('Translation request timed out');
          },
        );
        print('Online translation result: ${translation.text}');
        return translation.text;
      } catch (e) {
        print('Online translation error: $e');
        // Fallback to offline translation
        final offlineResult = _offlineTranslations[toLanguage]?[text] ?? text;
        print('Falling back to offline translation: $offlineResult');
        return offlineResult;
      }
    } else {
      // Use offline translations
      final offlineResult = _offlineTranslations[toLanguage]?[text] ?? text;
      print('Using offline translation: $offlineResult');
      return offlineResult;
    }
  }
}

// Widget to wrap text that needs translation
class AutoTranslateText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Key? key; 

  const AutoTranslateText({
    this.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  State<AutoTranslateText> createState() => _AutoTranslateTextState();
}

class _AutoTranslateTextState extends State<AutoTranslateText> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    // ignore: unnecessary_null_comparison
    if (languageProvider == null) {
      print('Error: LanguageProvider not found in widget tree for text: ${widget.text}');
      return Text(
        widget.text,
        style: widget.style,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
      );
    }

    // Force FutureBuilder to rebuild when selectedLanguage changes
    return Selector<LanguageProvider, String>(
      selector: (_, provider) => provider.selectedLanguage,
      builder: (context, selectedLanguage, _) {
        print('Rebuilding AutoTranslateText for text: "${widget.text}" with language: $selectedLanguage');
        return FutureBuilder<String>(
          // Use a unique key to ensure Future is re-run
          key: ValueKey('${widget.text}-$selectedLanguage'),
          future: languageProvider.translateText(widget.text, selectedLanguage),
          builder: (context, snapshot) {
            print('FutureBuilder snapshot for text "${widget.text}": ${snapshot.connectionState}, hasData: ${snapshot.hasData}, hasError: ${snapshot.hasError}');
            if (snapshot.connectionState == ConnectionState.waiting && snapshot.hasData == false) {
              print('Translation in progress for: "${widget.text}"');
              return Text(
                widget.text,
                style: widget.style,
                textAlign: widget.textAlign,
                maxLines: widget.maxLines,
                overflow: widget.overflow,
              );
            } else if (snapshot.hasError) {
              print('Error translating text "${widget.text}": ${snapshot.error}');
              return Text(
                widget.text,
                style: widget.style,
                textAlign: widget.textAlign,
                maxLines: widget.maxLines,
                overflow: widget.overflow,
              );
            } else {
              final translatedText = snapshot.data ?? widget.text;
              print('Rendered translated text: "$translatedText"');
              return Text(
                translatedText,
                style: widget.style,
                textAlign: widget.textAlign,
                maxLines: widget.maxLines,
                overflow: widget.overflow,
              );
            }
          },
        );
      },
    );
  }
}

// Example usage widget
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