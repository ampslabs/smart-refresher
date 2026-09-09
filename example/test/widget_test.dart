import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:iconify_sdk/iconify_sdk.dart';

void main() {
  testWidgets('SmartRefresher demo app smoke test',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const IconifyApp(child: SmartRefresherDemoApp()));
    // IconifyApp mounts its child only after the starter registry's 2s
    // package-path resolution timeout completes, so advance fake time.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify that our app title exists.
    expect(find.text('smart_refresher'), findsOneWidget);

    // Verify that we have some sections.
    final Finder headersFinder = find.text('HEADERS');
    final Finder footersFinder = find.text('FOOTERS');
    final Finder themingFinder = find.text('THEMING');
    expect(headersFinder, findsOneWidget);
    await tester.scrollUntilVisible(footersFinder, 100.0);
    expect(footersFinder, findsOneWidget);

    // Scroll until 'THEMING' is visible if needed.
    await tester.scrollUntilVisible(themingFinder, 100.0);
    expect(themingFinder, findsOneWidget);
  });
}
