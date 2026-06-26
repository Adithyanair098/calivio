import 'package:flutter/material.dart';
import '../app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 48,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text('Meal History', style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Your saved meals will appear here.',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}