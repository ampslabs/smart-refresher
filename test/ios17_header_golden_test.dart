import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpIndicator(
    WidgetTester tester, {
    required double progress,
    required Brightness brightness,
    double rotationValue = 0.0,
    double gradientOpacity = 0.0,
  }) {
    return tester.pumpWidget(
      CupertinoApp(
        theme: CupertinoThemeData(brightness: brightness),
        home: CupertinoPageScaffold(
          child: Builder(
            builder: (BuildContext context) {
              return Center(
                child: Ios17ActivityIndicator(
                  color: CupertinoColors.systemFill.resolveFrom(context),
                  radius: 10.0,
                  progress: progress,
                  rotationValue: rotationValue,
                  gradientOpacity: gradientOpacity,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('progress 0.0 golden', (WidgetTester tester) async {
    await pumpIndicator(
      tester,
      progress: 0.0,
      brightness: Brightness.light,
    );
    await expectLater(
      find.byType(Ios17ActivityIndicator),
      matchesGoldenFile('goldens/ios17_header_progress_0.png'),
    );
  });

  testWidgets('progress 0.5 golden', (WidgetTester tester) async {
    await pumpIndicator(
      tester,
      progress: 0.5,
      brightness: Brightness.light,
    );
    await expectLater(
      find.byType(Ios17ActivityIndicator),
      matchesGoldenFile('goldens/ios17_header_progress_05.png'),
    );
  });

  testWidgets('progress 1.0 pre-spin golden', (WidgetTester tester) async {
    await pumpIndicator(
      tester,
      progress: 1.0,
      brightness: Brightness.light,
    );
    await expectLater(
      find.byType(Ios17ActivityIndicator),
      matchesGoldenFile('goldens/ios17_header_progress_1.png'),
    );
  });

  testWidgets('spinning quarter-turn golden', (WidgetTester tester) async {
    await pumpIndicator(
      tester,
      progress: 1.0,
      brightness: Brightness.light,
      rotationValue: 0.25,
      gradientOpacity: 1.0,
    );
    await expectLater(
      find.byType(Ios17ActivityIndicator),
      matchesGoldenFile('goldens/ios17_header_spin_quarter.png'),
    );
  });

  testWidgets('dark progress 0.0 golden', (WidgetTester tester) async {
    await pumpIndicator(
      tester,
      progress: 0.0,
      brightness: Brightness.dark,
    );
    await expectLater(
      find.byType(Ios17ActivityIndicator),
      matchesGoldenFile('goldens/ios17_header_dark_progress_0.png'),
    );
  });

  testWidgets('dark progress 0.5 golden', (WidgetTester tester) async {
    await pumpIndicator(
      tester,
      progress: 0.5,
      brightness: Brightness.dark,
    );
    await expectLater(
      find.byType(Ios17ActivityIndicator),
      matchesGoldenFile('goldens/ios17_header_dark_progress_05.png'),
    );
  });

  testWidgets('dark progress 1.0 pre-spin golden', (WidgetTester tester) async {
    await pumpIndicator(
      tester,
      progress: 1.0,
      brightness: Brightness.dark,
    );
    await expectLater(
      find.byType(Ios17ActivityIndicator),
      matchesGoldenFile('goldens/ios17_header_dark_progress_1.png'),
    );
  });

  testWidgets('dark spinning quarter-turn golden', (WidgetTester tester) async {
    await pumpIndicator(
      tester,
      progress: 1.0,
      brightness: Brightness.dark,
      rotationValue: 0.25,
      gradientOpacity: 1.0,
    );
    await expectLater(
      find.byType(Ios17ActivityIndicator),
      matchesGoldenFile('goldens/ios17_header_dark_spin_quarter.png'),
    );
  });
}
