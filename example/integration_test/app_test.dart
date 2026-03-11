import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the first item, verify navigation', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find the first tab or a specific element you know exists in MainActivity.
      // We will look for text 'Pulltorefresh' which is the title.
      expect(find.text('Pulltorefresh'), findsOneWidget);

      // Scroll a little bit to ensure it doesn't crash
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pumpAndSettle();
    });
  });
}
