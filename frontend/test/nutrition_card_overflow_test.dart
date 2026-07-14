import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calorie_ai/features/food/presentation/widgets/nutrition_card.dart';

void main() {
  Widget buildGridCell({
    required double screenWidth,
    required double textScale,
    required String label,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: Size(screenWidth, 900),
        textScaler: TextScaler.linear(textScale),
      ),
      child: MaterialApp(
        home: Scaffold(
          body: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            children: [
              NutritionCard(
                label: label,
                value: '1234.5',
                unit: 'kcal',
                icon: Icons.local_fire_department_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  const widths = <String, double>{
    'small phone': 320,
    'large phone': 430,
    'tablet': 800,
  };
  const textScales = <double>[1.0, 1.3, 1.6, 2.0];
  const labels = <String>[
    'Calories',
    'Total Carbohydrates From Complex Sources',
  ];

  for (final width in widths.entries) {
    for (final scale in textScales) {
      for (final label in labels) {
        testWidgets(
          'no overflow on ${width.key} @ ${scale}x with "${label.length}" chars',
          (tester) async {
            await tester.pumpWidget(
              buildGridCell(
                screenWidth: width.value,
                textScale: scale,
                label: label,
              ),
            );

            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
