
   import 'package:autotranslator_widget/autotranslator_widget.dart';
import 'package:flutter/material.dart';
   import 'package:provider/provider.dart';

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
   