import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_manager/image_manager_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Multi-Folder Image Viewer',
      theme: ThemeData(
        // primarySwatch: Colors.blue,
      ),
      locale: Locale('zh'), // 设置默认语言为中文
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // 英文
        Locale('zh'), // 中文
      ],
      home: const ImageManagerScreen(),
    );
  }
}

