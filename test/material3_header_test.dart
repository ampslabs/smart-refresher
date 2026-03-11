import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

void main() {
  group('Material3Header', () {
    testWidgets('renders without error in default theme', (
      WidgetTester tester,
    ) async {
      final GlobalKey<Material3HeaderState> key =
          GlobalKey<Material3HeaderState>();

      await tester.pumpWidget(_buildTestApp(headerKey: key));

      expect(key.currentState, isNotNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses colorScheme.primary when no color prop given', (
      WidgetTester tester,
    ) async {
      final GlobalKey<Material3HeaderState> key =
          GlobalKey<Material3HeaderState>();
      final ColorScheme colorScheme =
          ColorScheme.fromSeed(seedColor: Colors.teal);

      await tester.pumpWidget(
        _buildTestApp(
          headerKey: key,
          theme: ThemeData(colorScheme: colorScheme, useMaterial3: true),
        ),
      );

      final CircularProgressIndicator indicator = _indicatorFor(
        key.currentState!,
        RefreshStatus.canRefresh,
      );

      expect(indicator.color, colorScheme.primary);
    });

    testWidgets('respects explicit color prop', (WidgetTester tester) async {
      final GlobalKey<Material3HeaderState> key =
          GlobalKey<Material3HeaderState>();
      const Color customColor = Colors.orange;

      await tester.pumpWidget(
        _buildTestApp(
          header: Material3Header(key: key, color: customColor),
        ),
      );

      final CircularProgressIndicator indicator = _indicatorFor(
        key.currentState!,
        RefreshStatus.canRefresh,
      );

      expect(indicator.color, customColor);
    });

    testWidgets('respects ProgressIndicatorThemeData.color', (
      WidgetTester tester,
    ) async {
      final GlobalKey<Material3HeaderState> key =
          GlobalKey<Material3HeaderState>();
      const Color themedColor = Colors.deepOrange;

      await tester.pumpWidget(
        _buildTestApp(
          headerKey: key,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: themedColor,
            ),
          ),
        ),
      );

      final CircularProgressIndicator indicator = _indicatorFor(
        key.currentState!,
        RefreshStatus.canRefresh,
      );

      expect(indicator.color, themedColor);
    });

    testWidgets('dark mode colors update from the theme', (
      WidgetTester tester,
    ) async {
      final GlobalKey<Material3HeaderState> key =
          GlobalKey<Material3HeaderState>();
      final ColorScheme colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      );

      await tester.pumpWidget(
        _buildTestApp(
          headerKey: key,
          theme: ThemeData(colorScheme: colorScheme, useMaterial3: true),
        ),
      );

      final Material3HeaderState state = key.currentState!;
      final CircularProgressIndicator indicator = _indicatorFor(
        state,
        RefreshStatus.canRefresh,
      );
      final Material material = _materialFor(state, RefreshStatus.canRefresh);

      expect(indicator.color, colorScheme.primary);
      expect(material.color, colorScheme.surfaceContainerLow);
    });

    testWidgets('scale animation runs on canRefresh', (
      WidgetTester tester,
    ) async {
      final GlobalKey<Material3HeaderState> key =
          GlobalKey<Material3HeaderState>();
      await tester.pumpWidget(_buildTestApp(headerKey: key));

      final Material3HeaderState state = key.currentState!;
      state.onModeChange(RefreshStatus.canRefresh);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final ScaleTransition transition = _scaleTransitionFor(
        state,
        RefreshStatus.canRefresh,
      );

      expect(transition.scale.value, greaterThan(0.0));
    });

    testWidgets('drag progress updates from a pull gesture', (
      WidgetTester tester,
    ) async {
      final GlobalKey<Material3HeaderState> key =
          GlobalKey<Material3HeaderState>();
      final RefreshController controller = RefreshController();
      await tester.pumpWidget(
        _buildTestApp(headerKey: key, controller: controller),
      );

      await tester.drag(
        find.byType(Scrollable),
        const Offset(0.0, 40.0),
        touchSlopY: 0.0,
      );
      await tester.pump();

      final CircularProgressIndicator indicator = _indicatorFor(
        key.currentState!,
        controller.headerStatus ?? RefreshStatus.idle,
      );

      expect(controller.headerStatus, RefreshStatus.idle);
      expect(indicator.value, greaterThan(0.0));
      expect(indicator.value, lessThan(1.0));
    });

    testWidgets('scale animation reverses on idle', (
      WidgetTester tester,
    ) async {
      final GlobalKey<Material3HeaderState> key =
          GlobalKey<Material3HeaderState>();
      await tester.pumpWidget(_buildTestApp(headerKey: key));

      final Material3HeaderState state = key.currentState!;
      state.onModeChange(RefreshStatus.canRefresh);
      await tester.pumpAndSettle();
      state.onModeChange(RefreshStatus.idle);
      await tester.pumpAndSettle();

      final ScaleTransition transition = _scaleTransitionFor(
        state,
        RefreshStatus.idle,
      );

      expect(transition.scale.value, 0.0);
    });

    testWidgets('shows checkmark on completed', (WidgetTester tester) async {
      final GlobalKey<Material3HeaderState> key =
          GlobalKey<Material3HeaderState>();
      await tester.pumpWidget(_buildTestApp(headerKey: key));

      key.currentState!.onModeChange(RefreshStatus.completed);
      await tester.pump(const Duration(milliseconds: 200));

      final Icon icon = _iconFor(key.currentState!, RefreshStatus.completed);
      expect(icon.icon, Icons.check_circle_outline);
    });

    testWidgets('shows error icon on failed', (WidgetTester tester) async {
      final GlobalKey<Material3HeaderState> key =
          GlobalKey<Material3HeaderState>();
      await tester.pumpWidget(_buildTestApp(headerKey: key));

      key.currentState!.onModeChange(RefreshStatus.failed);
      await tester.pump(const Duration(milliseconds: 200));

      final Icon icon = _iconFor(key.currentState!, RefreshStatus.failed);
      expect(icon.icon, Icons.error_outline);
    });

    testWidgets('disposing during animation does not throw', (
      WidgetTester tester,
    ) async {
      final GlobalKey<Material3HeaderState> key =
          GlobalKey<Material3HeaderState>();
      await tester.pumpWidget(_buildTestApp(headerKey: key));

      key.currentState!.onModeChange(RefreshStatus.completed);
      await tester.pump(const Duration(milliseconds: 200));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('uses the 2024 CircularProgressIndicator style flag', (
      WidgetTester tester,
    ) async {
      final GlobalKey<Material3HeaderState> key =
          GlobalKey<Material3HeaderState>();
      await tester.pumpWidget(_buildTestApp(headerKey: key));

      final CircularProgressIndicator indicator = _indicatorFor(
        key.currentState!,
        RefreshStatus.canRefresh,
      );

      // ignore: deprecated_member_use
      expect(indicator.year2023, isFalse);
    });
  });
}

Widget _buildTestApp({
  ThemeData? theme,
  RefreshController? controller,
  GlobalKey<Material3HeaderState>? headerKey,
  RefreshIndicator? header,
}) {
  final RefreshController resolvedController =
      controller ?? RefreshController();

  return MaterialApp(
    theme: theme ??
        ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
    home: Scaffold(
      body: SmartRefresher.builder(
        controller: resolvedController,
        onRefresh: () async {},
        builder: (BuildContext context, RefreshPhysics physics) {
          return CustomScrollView(
            physics: physics,
            slivers: <Widget>[
              header ?? Material3Header(key: headerKey),
              SliverList.builder(
                itemCount: 20,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(title: Text('Item $index'));
                },
              ),
            ],
          );
        },
      ),
    ),
  );
}

SizedBox _outerBoxFor(Material3HeaderState state, RefreshStatus mode) {
  return state.buildContent(state.context, mode) as SizedBox;
}

ScaleTransition _scaleTransitionFor(
    Material3HeaderState state, RefreshStatus mode) {
  final Center center = _outerBoxFor(state, mode).child! as Center;
  return center.child! as ScaleTransition;
}

Material _materialFor(Material3HeaderState state, RefreshStatus mode) {
  final Semantics semantics = _scaleTransitionFor(state, mode).child! as Semantics;
  return semantics.child! as Material;
}

Widget _innerChildFor(Material3HeaderState state, RefreshStatus mode) {
  final SizedBox innerBox = _materialFor(state, mode).child! as SizedBox;
  final Center center = innerBox.child! as Center;
  return center.child!;
}

CircularProgressIndicator _indicatorFor(
  Material3HeaderState state,
  RefreshStatus mode,
) {
  final SizedBox box = _innerChildFor(state, mode) as SizedBox;
  return box.child! as CircularProgressIndicator;
}

Icon _iconFor(Material3HeaderState state, RefreshStatus mode) {
  final FadeTransition fade = _innerChildFor(state, mode) as FadeTransition;
  return fade.child! as Icon;
}
