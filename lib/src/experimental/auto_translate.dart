import 'dart:async';
import 'dart:io';
import 'package:autotranslator_widget/src/Translations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Offline data (import from your own file)
const Map<String, Map<String, String>> _offlineTranslations = offlineTranslations;

/// Language provider with caching & efficient connectivity monitoring
class LanguageProvider2 with ChangeNotifier {
  final GoogleTranslator translator;
  final Connectivity connectivity;

  String _selectedLanguage = 'en';
  bool _isOnline = true;

  /// Translation cache: { "es": { "Hello": "Hola" } }
  final Map<String, Map<String, String>> _cache = {};

  StreamSubscription? _connectivitySubscription;

  String get selectedLanguage => _selectedLanguage;
  bool get isOnline => _isOnline;

  LanguageProvider2({
    GoogleTranslator? translator,
    Connectivity? connectivity,
  })  : translator = translator ?? GoogleTranslator(),
        connectivity = connectivity ?? Connectivity() {
    _initConnectivityListener();
  }

  Future<bool> _hasInternet() async {
  try {
    final result = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 3));
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } catch (_) {}
  return false;
}

  /// listen to connectivity changes ONCE.
  void _initConnectivityListener() {
    // _connectivitySubscription =
    //     this.connectivity.onConnectivityChanged.listen((results) {
    //   final online = results == ConnectivityResult.mobile ||
    //       results == ConnectivityResult.wifi ||
    //       results == ConnectivityResult.ethernet;
    //     print(' Connectivity changed: ${online ? 'Online' : 'Offline'}');
    //   if (online != _isOnline) {
    //     _isOnline = online;
    //     notifyListeners();
    //   }
    // });
    _connectivitySubscription =
      connectivity.onConnectivityChanged.listen((results) async {
    final connected =
        results == ConnectivityResult.mobile ||
        results == ConnectivityResult.wifi ||
        results == ConnectivityResult.ethernet;

      print("Device Connectivity changed: ${connected ? 'Online' : 'Offline'}");
    if (!connected) {
      // Interface may be down → report offline
      _isOnline = false;
      notifyListeners();
      return;
    }

    // Check actual internet access
    final internet = await _hasInternet();

    if (_isOnline != internet) {
      _isOnline = internet;
      notifyListeners();
    }
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
class AutoTranslateText2 extends StatefulWidget {
  final String text;
  final bool? softwrap;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AutoTranslateText2({
    super.key,
    required this.text,
    this.softwrap,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<AutoTranslateText2> createState() => _AutoTranslateText2State();
}

class _AutoTranslateText2State extends State<AutoTranslateText2> {
  Future<String>? _future;
  String _lastLanguage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _triggerTranslationIfNeeded();
  }

  @override
  void didUpdateWidget(covariant AutoTranslateText2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _future = null;
      _triggerTranslationIfNeeded();
    }
  }

  void _triggerTranslationIfNeeded() {
    final provider = Provider.of<LanguageProvider2>(context, listen: false);

    if (_future == null || _lastLanguage != provider.selectedLanguage) {
      _lastLanguage = provider.selectedLanguage;
      _future = provider.translateText(widget.text, _lastLanguage);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LanguageProvider2>(context);

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
