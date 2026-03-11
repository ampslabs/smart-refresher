import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('SmartRefresher demo app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartRefresherDemoApp());

    // Verify that our app title exists.
    expect(find.text('smart_refresher'), findsOneWidget);

    // Verify that we have some sections.
    expect(find.text('HEADERS'), findsOneWidget);
    expect(find.text('FOOTERS'), findsOneWidget);

    // Scroll until 'THEMING' is visible if needed.
    final Finder themingFinder = find.text('THEMING');
    await tester.scrollUntilVisible(themingFinder, 100.0);
    expect(themingFinder, findsOneWidget);
  });
}
