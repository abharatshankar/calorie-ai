import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calorie_ai/app.dart';

void main() {
  testWidgets('App shell builds with auth routing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CalorieAiApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
