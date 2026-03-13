import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

Widget _buildRefresher({
  required RefreshController controller,
  GlassHeader header = const GlassHeader(),
  Future<void> Function()? onRefresh,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      body: SmartRefresher(
        controller: controller,
        header: header,
        onRefresh: onRefresh,
        child: ListView(
          children: <Widget>[
            for (int i = 0; i < 20; i++) ListTile(title: Text('Item $i')),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('GlassHeader renders without error', (WidgetTester tester) async {
    final RefreshController controller = RefreshController();
    await tester.pumpWidget(_buildRefresher(controller: controller));
    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  testWidgets('GlassHeader panel hidden in idle state', (WidgetTester tester) async {
    final RefreshController controller = RefreshController();
    await tester.pumpWidget(_buildRefresher(controller: controller));

    final Finder scaleFinder = find.byType(ScaleTransition);
    final ScaleTransition scaleWidget = tester.widget<ScaleTransition>(
      scaleFinder.first,
    );
    expect(scaleWidget.scale.value, 0.0);
    controller.dispose();
  });

  testWidgets('BackdropFilter is present', (WidgetTester tester) async {
    final RefreshController controller = RefreshController();
    await tester.pumpWidget(_buildRefresher(controller: controller));

    await tester.drag(find.byType(Scrollable), const Offset(0, 100));
    await tester.pump();

    expect(find.byType(BackdropFilter), findsOneWidget);
    controller.dispose();
  });

  testWidgets('GlassHeader uses dark tint in dark mode', (WidgetTester tester) async {
    final RefreshController controller = RefreshController();
    await tester.pumpWidget(
      _buildRefresher(
        controller: controller,
        theme: ThemeData(brightness: Brightness.dark),
      ),
    );

    await tester.drag(find.byType(Scrollable), const Offset(0, 100));
    await tester.pump();

    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  testWidgets('GlassHeader accepts custom color', (WidgetTester tester) async {
    final RefreshController controller = RefreshController();
    await tester.pumpWidget(
      _buildRefresher(
        controller: controller,
        header: const GlassHeader(color: Colors.red),
      ),
    );

    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  testWidgets('GlassHeader shows spinner in refreshing state', (WidgetTester tester) async {
    final RefreshController controller = RefreshController(initialRefresh: true);
    await tester.pumpWidget(
      _buildRefresher(
        controller: controller,
        onRefresh: () async {
          await Future<void>.delayed(const Duration(seconds: 1));
          controller.refreshCompleted();
        },
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    
    // Complete the timer to avoid pending timer error
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    
    controller.dispose();
  });

  testWidgets('GlassHeader hides text when showText is false', (WidgetTester tester) async {
    final RefreshController controller = RefreshController();
    await tester.pumpWidget(
      _buildRefresher(
        controller: controller,
        header: const GlassHeader(showText: false),
      ),
    );

    await tester.drag(find.byType(Scrollable), const Offset(0, 100));
    await tester.pump();

    expect(find.text('Pull to refresh'), findsNothing);
    controller.dispose();
  });

  testWidgets('GlassHeader disposes cleanly during animation', (WidgetTester tester) async {
    final RefreshController controller = RefreshController(initialRefresh: true);
    await tester.pumpWidget(
      _buildRefresher(
        controller: controller,
        onRefresh: () async => controller.refreshCompleted(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));

    expect(tester.takeException(), isNull);
    controller.dispose();
  });
}
