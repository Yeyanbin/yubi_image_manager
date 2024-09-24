// main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Progress Bar Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Progress: ${Utils.formatPercentage(_progress)}'),
              SizedBox(height: 20),
              // ProgressManager.buildProgressBar(_progress),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProgress,
                child: Text('Increase Progress'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateProgress() {
    setState(() {
      _progress += 0.1;
      if (_progress > 1.0) {
        _progress = 0.0;  // 重置进度条
      }
    });
  }
}


class Utils {
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
}