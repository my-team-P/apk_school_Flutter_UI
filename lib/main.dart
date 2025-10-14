// import 'package:admin/controllers/menu_app_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:admin/first_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//           create: (_) => MenuAppController(),
//         ),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Flutter Admin Panel',
//         theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Roboto'),
//         home: const UserTypeSelectionApp(), // أول شاشة
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/a/settings_provider.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/first_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MenuAppController()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Admin Panel',
          theme: settings.darkMode
              ? ThemeData.dark().copyWith(
                  primaryColor: const Color(0xFF667eea),
                  scaffoldBackgroundColor: Colors.grey[900],
                )
              : ThemeData.light().copyWith(
                  primaryColor: const Color(0xFF667eea),
                  scaffoldBackgroundColor: Colors.grey[50],
                ),
          locale: Locale(settings.language == "English" ? "en" : "ar"),
          home: const UserTypeSelectionPage(), // أو أي شاشة أولية تريدها
        );
      },
    );
  }
}
