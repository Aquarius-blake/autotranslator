import 'dart:async';

import 'package:autotranslator_widget/src/Translations.dart';
import 'package:autotranslator_widget/src/auto_translate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'autotranslator_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  GoogleTranslator,
  Connectivity,
  InternetConnection,
  Translation,
])
void  main() {
  late MockGoogleTranslator mockTranslator;
  late MockConnectivity mockConnectivity;
  late MockInternetConnection mockInternetConnection;
  late MockTranslation mockTranslation;
  late LanguageProvider languageProvider;

  setUp(() {
    mockTranslator = MockGoogleTranslator();
    mockConnectivity = MockConnectivity();
    mockInternetConnection = MockInternetConnection();
    mockTranslation = MockTranslation();

    // Default: online
    when(mockInternetConnection.onStatusChange).thenAnswer((_) {
      return Stream.value(InternetStatus.connected);
    });

    languageProvider = LanguageProvider(
      translator: mockTranslator,
      connectivity: mockConnectivity,
    );
  });

  tearDown(() {
    languageProvider.dispose();
  });

  group('LanguageProvider', () {
    test('initial state is English and online', () {
      expect(languageProvider.selectedLanguage, 'en');
      expect(languageProvider.isOnline, true);
    });

    test('setLanguage debounces and updates language', () async {
      var notified = 0;
      languageProvider.addListener(() => notified++);

      languageProvider.setLanguage('es');
      languageProvider.setLanguage('fr'); // rapid fire
      languageProvider.setLanguage('de');

      await Future.delayed(const Duration(milliseconds: 200));
      expect(languageProvider.selectedLanguage, 'de');
      expect(notified, 1); // only one rebuild
    });

    test('caches online translations', () async {
      when(mockTranslation.text).thenReturn('¡Hola!');
      when(mockTranslator.translate('Hello', to: 'es'))
          .thenAnswer((_) async => mockTranslation);

      final result1 = await languageProvider.translateText('Hello', 'es');
      final result2 = await languageProvider.translateText('Hello', 'es');

      expect(result1, '¡Hola!');
      expect(result2, '¡Hola!');
      verify(mockTranslator.translate('Hello', to: 'es')).called(1); // cached!
    });

    test('falls back to offline when online fails', () async {
      when(mockTranslator.translate('Hello', to: 'es'))
          .thenThrow(Exception('Network error'));

      final result = await languageProvider.translateText('Hello', 'es');
      expect(result, 'Hola'); // from offlineTranslations
    });

    test('uses offline translation when offline', () async {
      // Simulate going offline
      final controller = StreamController<InternetStatus>();
      when(mockInternetConnection.onStatusChange)
          .thenAnswer((_) => controller.stream);
      languageProvider.dispose(); // restart with new mock
      languageProvider = LanguageProvider(
        translator: mockTranslator,
        connectivity: mockConnectivity,
      );

      controller.add(InternetStatus.disconnected);
      await Future.delayed(const Duration(milliseconds: 100));

      final result = await languageProvider.translateText('Hello', 'es');
      expect(result, 'Hola');
      expect(languageProvider.isOnline, false);

      controller.close();
    });

    test('caches offline results too', () async {
      // Force offline
      final controller = StreamController<InternetStatus>();
      when(mockInternetConnection.onStatusChange)
          .thenAnswer((_) => controller.stream);
      languageProvider.dispose();
      languageProvider = LanguageProvider(
        translator: mockTranslator,
        connectivity: mockConnectivity,
      );
      controller.add(InternetStatus.disconnected);
      await Future.delayed(const Duration(milliseconds: 100));

      final r1 = await languageProvider.translateText('Hello', 'es');
      final r2 = await languageProvider.translateText('Hello', 'es');

      expect(r1, 'Hola');
      expect(r2, 'Hola');
      verifyNever(mockTranslator.translate(any, to: any));
    });
  });

  group('AutoTranslateText Widget', () {
    testWidgets('displays text and translates when language changes',
        (WidgetTester tester) async {
      when(mockTranslation.text).thenReturn('¡Bienvenido!');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: languageProvider,
          child: const MaterialApp(
            home: Scaffold(
              body: AutoTranslateText(text: 'Welcome'),
            ),
          ),
        ),
      );

      expect(find.text('Welcome'), findsOneWidget);

      // Change language
      when(mockTranslator.translate('Welcome', to: 'es'))
          .thenAnswer((_) async => mockTranslation);

      languageProvider.setLanguage('es');
      await tester.pump(); // trigger rebuild
      await tester.pump(const Duration(seconds: 1)); // wait for future

      expect(find.text('¡Bienvenido!'), findsOneWidget);
    });

    testWidgets('uses cached translation on second render', (tester) async {
      when(mockTranslation.text).thenReturn('Bonjour');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: languageProvider,
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  AutoTranslateText(text: 'Hello'),
                  AutoTranslateText(text: 'Hello'), // same text
                ],
              ),
            ),
          ),
        ),
      );

      languageProvider.setLanguage('fr');
      when(mockTranslator.translate('Hello', to: 'fr'))
          .thenAnswer((_) async => mockTranslation);

      await tester.pumpAndSettle();

      verify(mockTranslator.translate('Hello', to: 'fr')).called(1);
      expect(find.text('Bonjour'), findsNWidgets(2));
    });

    testWidgets('shows original text while loading', (tester) async {
      final completer = Completer<Translation>();
      when(mockTranslator.translate('Loading', to: 'es'))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: languageProvider,
          child: const MaterialApp(
            home: Scaffold(body: AutoTranslateText(text: 'Loading')),
          ),
        ),
      );

      languageProvider.setLanguage('es');
      await tester.pump();

      expect(find.text('Loading'), findsOneWidget); // placeholder

      // completer.complete(Translation.namedConstructor(text: 'Cargando', sourceLanguage: null, targetLanguage: null));
      // await tester.pump();

      // expect(find.text('Cargando'), findsOneWidget);
    });
  });
}