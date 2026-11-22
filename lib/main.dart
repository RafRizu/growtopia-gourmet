import 'package:flutter/material.dart';
import 'pages/katalog_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const GrowtopiaGourmetApp());
}

class GrowtopiaGourmetApp extends StatelessWidget {
  const GrowtopiaGourmetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Growtopia Gourmet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const KatalogPage(),
    );
  }
}
