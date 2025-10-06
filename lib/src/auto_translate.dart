import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Offline translation data (example key-value store)
const Map<String, Map<String, String>> _offlineTranslations = {
  'en': {
    'Welcome to my application!': 'Welcome to my application!',
    'This is a sample text to demonstrate translation.': 'This is a sample text to demonstrate translation.',
    'My App': 'My App',
    'Register': 'Register',
    'Login': 'Login',
    'Logout': 'Logout',
    'Settings': 'Settings',
    'Profile': 'Profile',
    
  },
  'es': {
    'Welcome to my application!': '¡Bienvenido a mi aplicación!',
    'This is a sample text to demonstrate translation.': 'Este es un texto de muestra para demostrar la traducción.',
    'My App': 'Mi Aplicación',
    'Register': 'Registrarse',
    'Login': 'Iniciar sesión',
    'Logout': 'Cerrar sesión',
    'Settings': 'Configuraciones',
    'Profile': 'Perfil',
  },
  'fr': {
    'Welcome to my application!': 'Bienvenue dans mon application !',
    'This is a sample text to demonstrate translation.': 'Ceci est un texte d\'exemple pour démontrer la traduction.',
    'My App': 'Mon Application',
    'Register': 'S\'inscrire',
    'Login': 'Se connecter',
    'Logout': 'Se déconnecter',
    'Settings': 'Paramètres',
    'Profile': 'Profil',
  },
  'de': {
    'Welcome to my application!': 'Willkommen in meiner Anwendung!',
    'This is a sample text to demonstrate translation.': 'Dies ist ein Beispieltext zur Demonstration der Übersetzung.',
    'My App': 'Meine App',
    'Register': 'Registrieren',
    'Login': 'Anmelden',
    'Logout': 'Abmelden',
    'Settings': 'Einstellungen',
    'Profile': 'Profil',
  },
};

// Language provider to manage the selected language and translation mode
class LanguageProvider with ChangeNotifier {
  String _selectedLanguage = 'en'; // Default language is English
  final GoogleTranslator translator; // Made public for testing
  final Connectivity connectivity; // Made public for testing
  bool _isOnline = true;

  String get selectedLanguage => _selectedLanguage;
  bool get isOnline => _isOnline;

  LanguageProvider({GoogleTranslator? translator, Connectivity? connectivity})
      : translator = translator ?? GoogleTranslator(),
        connectivity = connectivity ?? Connectivity() {
    _checkConnectivity();
  }

  void setLanguage(String languageCode) {
    _selectedLanguage = languageCode;
    notifyListeners();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResults = await connectivity.checkConnectivity();
    _isOnline = connectivityResults.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);
    notifyListeners();
  }

  Future<String> translateText(String text, String toLanguage) async {
    await _checkConnectivity();
    
    if (_isOnline) {
      try {
        final translation = await translator.translate(text, to: toLanguage);
        return translation.text;
      } catch (e) {
        debugPrint('Online translation error: $e');
        // Fallback to offline translation
        return _offlineTranslations[toLanguage]?[text] ?? text;
      }
    } else {
      // Use offline translations
      return _offlineTranslations[toLanguage]?[text] ?? text;
    }
  }
}

// Widget to wrap text that needs translation
class AutoTranslateText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AutoTranslateText({
    Key? key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return FutureBuilder<String>(
      future: languageProvider.translateText(text, languageProvider.selectedLanguage),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            text,
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          );
        } else if (snapshot.hasError) {
          debugPrint('Error translating text: ${snapshot.error}');
          return Text(
            text,
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          );
        } else {
          return Text(
            snapshot.data ?? text,
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          );
        }
      },
    );
  }
}

// Example widget
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