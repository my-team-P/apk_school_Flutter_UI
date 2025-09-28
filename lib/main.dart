import 'package:admin/controllers/menu_app_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/login.blade.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MenuAppController(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Admin Panel',
        theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Roboto'),
        home: const LoginPage(), // أول شاشة
      ),
    );
  }
}
