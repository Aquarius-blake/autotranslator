import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:translator/translator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:autotranslator_widget/autotranslator_widget.dart';
import 'autotranslator_test.mocks.dart';

// Mock classes
@GenerateMocks([GoogleTranslator, Connectivity, Translation])
void main() {
  late MockGoogleTranslator mockTranslator;
  late MockConnectivity mockConnectivity;
  late MockTranslation mockTranslation;
  late LanguageProvider languageProvider;

  setUp(() {
    mockTranslator = MockGoogleTranslator();
    mockConnectivity = MockConnectivity();
    mockTranslation = MockTranslation();
    // Provide a default stub for checkConnectivity to avoid MissingStubError
    when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);
    // Initialize LanguageProvider with mocked dependencies
    languageProvider = LanguageProvider(
      translator: mockTranslator,
      connectivity: mockConnectivity,
    );
  });

  group('LanguageProvider Tests', () {
    test('Initial language is English', () {
      expect(languageProvider.selectedLanguage, 'en');
    });

    test('setLanguage updates selected language and notifies listeners', () {
      var notified = false;
      languageProvider.addListener(() {
        notified = true;
      });

      languageProvider.setLanguage('es');
      expect(languageProvider.selectedLanguage, 'es');
      expect(notified, true);
    });

    test('translateText returns offline translation when offline', () async {
      // Mock connectivity to simulate offline state
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final result = await languageProvider.translateText(
        'Welcome to my application!',
        'es',
      );
      expect(result, '¡Bienvenido a mi aplicación!');
      expect(languageProvider.isOnline, false);
    });

    test('translateText uses online translation when online', () async {
      // Mock connectivity to simulate online state
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      // Mock translator response
      when(mockTranslation.text).thenReturn('Bonjour dans mon application !');
      when(mockTranslator.translate('Welcome to my application!', to: 'fr'))
          .thenAnswer((_) async => mockTranslation);

      final result = await languageProvider.translateText(
        'Welcome to my application!',
        'fr',
      );
      expect(result, 'Bonjour dans mon application !');
      expect(languageProvider.isOnline, true);
    });

    test('translateText falls back to offline translation on online failure', () async {
      // Mock connectivity to simulate online state
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      // Mock translator to throw an error
      when(mockTranslator.translate('Welcome to my application!', to: 'es'))
          .thenThrow(Exception('Translation API error'));

      final result = await languageProvider.translateText(
        'Welcome to my application!',
        'es',
      );
      expect(result, '¡Bienvenido a mi aplicación!');
      expect(languageProvider.isOnline, true);
    });

    test('translateText returns original text if no translation available', () async {
      // Mock connectivity to simulate offline state
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final result = await languageProvider.translateText(
        'Non-existent text',
        'es',
      );
      expect(result, 'Non-existent text');
      expect(languageProvider.isOnline, false);
    });
  });
}