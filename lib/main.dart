import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Style the system status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const NutriLensApp());
}

class NutriLensApp extends StatelessWidget {
  const NutriLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _PlaceholderScreen(),
    );
  }
}

// Temporary placeholder — will be replaced in Step 2
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NutriLens')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'NutriLens',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'AI-Powered Food Nutrition Tracker',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Theme is working ✓'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
          ],
        ),
      ),
    );
  }
}