import 'dart:async';
import 'package:autotranslator_widget/src/Translations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Offline data
const Map<String, Map<String, String>> _offlineTranslations = offlineTranslations;

/// Language provider with caching & efficient connectivity monitoring
class LanguageProvider with ChangeNotifier {
  final GoogleTranslator translator;
  final Connectivity connectivity;

  String _selectedLanguage = 'en';
  bool _isOnline = true;

  /// Translation cache: { "es": { "Hello": "Hola" } }
  final Map<String, Map<String, String>> _cache = {};

  StreamSubscription? _connectivitySubscription;

  String get selectedLanguage => _selectedLanguage;
  bool get isOnline => _isOnline;

  LanguageProvider({
    GoogleTranslator? translator,
    Connectivity? connectivity,
  })  : translator = translator ?? GoogleTranslator(),
        connectivity = connectivity ?? Connectivity() {
    _initConnectivityListener();
  }

//   Future<bool> _hasInternet() async {
//   try {
//     final result = await InternetAddress.lookup('google.com')
//         .timeout(const Duration(seconds: 3));
//     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//       return true;
//     }
//   } catch (_) {}
//   return false;
// }

  /// listen to connectivity changes ONCE.
  void _initConnectivityListener() {
   
  InternetConnection().onStatusChange.listen((status) {
  _isOnline = status == InternetStatus.connected;
  print(' Internet connection status changed: ${_isOnline ? 'Online' : 'Offline'}');
  notifyListeners();
});
  }

  /// Set language with tiny debounce to avoid rebuild storms
  Timer? _debounce;
  void setLanguage(String languageCode) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 120), () {
      _selectedLanguage = languageCode;
      notifyListeners();
    });
  }

  /// Attempts to translate with cache → online → offline fallback
  Future<String> translateText(String text, String toLanguage) async {
    // Return cached value immediately
    if (_cache[toLanguage] != null && _cache[toLanguage]![text] != null) {
      return _cache[toLanguage]![text]!;
    }

    // Try online translation if available
    if (_isOnline) {
      try {
        final result = await translator
            .translate(text, to: toLanguage)
            .timeout(const Duration(seconds: 12));

        final translated = result.text;

        // Cache result
        _cache.putIfAbsent(toLanguage, () => {})[text] = translated;

        return translated;
      } catch (_) {
        // Online failed → continue to offline fallback
      }
    }

    // Offline fallback
    final offlineResult = _offlineTranslations[toLanguage]?[text] ?? text;

    // Cache offline result
    _cache.putIfAbsent(toLanguage, () => {})[text] = offlineResult;

    return offlineResult;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _debounce?.cancel();
    super.dispose();
  }
}

/// Widget for automatic translation with cached future
class AutoTranslateText extends StatefulWidget {
  final String text;
  final bool? softwrap;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AutoTranslateText({
    super.key,
    required this.text,
    this.softwrap,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<AutoTranslateText> createState() => _AutoTranslateTextState();
}

class _AutoTranslateTextState extends State<AutoTranslateText> {
  Future<String>? _future;
  String _lastLanguage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _triggerTranslationIfNeeded();
  }

  @override
  void didUpdateWidget(covariant AutoTranslateText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _future = null;
      _triggerTranslationIfNeeded();
    }
  }

  void _triggerTranslationIfNeeded() {
    final provider = Provider.of<LanguageProvider>(context, listen: false);

    if (_future == null || _lastLanguage != provider.selectedLanguage) {
      _lastLanguage = provider.selectedLanguage;
      _future = provider.translateText(widget.text, _lastLanguage);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LanguageProvider>(context);

    // If language changes, trigger new future automatically
    if (_lastLanguage != provider.selectedLanguage) {
      _triggerTranslationIfNeeded();
    }

    return FutureBuilder<String>(
      future: _future,
      builder: (context, snapshot) {
        final text = snapshot.data ?? widget.text;

        return Text(
          text,
          style: widget.style,
          softWrap: widget.softwrap,
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
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