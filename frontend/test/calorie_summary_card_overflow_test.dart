import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calorie_ai/features/dashboard/presentation/widgets/calorie_summary_card.dart';

void main() {
  Widget buildGridCell({
    required double screenWidth,
    required double textScale,
    required String title,
    required int calories,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: Size(screenWidth, 900),
        textScaler: TextScaler.linear(textScale),
      ),
      child: MaterialApp(
        home: Scaffold(
          body: GridView(
            // Mirrors the dashboard summary grid (the tightest cell we ship).
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            children: [
              CalorieSummaryCard(
                title: title,
                calories: calories,
                icon: Icons.today_outlined,
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
  const titles = <String>['Daily Calories', 'Average Calories Per Logged Meal'];
  const calorieValues = <int>[0, 88888];

  for (final width in widths.entries) {
    for (final scale in textScales) {
      for (final title in titles) {
        for (final calories in calorieValues) {
          testWidgets(
            'no overflow on ${width.key} @ ${scale}x '
            '("${title.length}" chars, $calories kcal)',
            (tester) async {
              await tester.pumpWidget(
                buildGridCell(
                  screenWidth: width.value,
                  textScale: scale,
                  title: title,
                  calories: calories,
                ),
              );

              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
}
