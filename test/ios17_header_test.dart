import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('debugIOS17HeaderTickAlphas', () {
    test('returns zero visible ticks at progress 0.0', () {
      final List<int> alphas = debugIOS17HeaderTickAlphas(
        progress: 0.0,
      );

      expect(alphas.where((int alpha) => alpha > 0), isEmpty);
    });

    test('returns six visible ticks at progress 0.5', () {
      final List<int> alphas = debugIOS17HeaderTickAlphas(
        progress: 0.5,
      );

      expect(alphas.where((int alpha) => alpha > 0).length, 6);
      expect(alphas.take(6), everyElement(kIOS17HeaderAlphaValues.first));
      expect(alphas.skip(6), everyElement(0));
    });

    test('returns twelve visible ticks at progress 1.0', () {
      final List<int> alphas = debugIOS17HeaderTickAlphas(
        progress: 1.0,
      );

      expect(alphas.where((int alpha) => alpha > 0).length, 12);
      expect(alphas, everyElement(kIOS17HeaderAlphaValues.first));
    });

    test('applies alpha gradient when spinning', () {
      final List<int> alphas = debugIOS17HeaderTickAlphas(
        progress: 1.0,
        rotationValue: 0.25,
        gradientOpacity: 1.0,
      );

      expect(alphas, <int>[47, 47, 47, 255, 220, 184, 148, 112, 76, 47, 47, 47]);
    });
  });

  group('debugIOS17HeaderLastUpdatedText', () {
    test('returns default just-now copy', () {
      final DateTime now = DateTime(2026, 3, 11, 12);
      expect(
        debugIOS17HeaderLastUpdatedText(updatedAt: now, now: now),
        'Updated just now',
      );
    });

    test('returns custom builder copy', () {
      final DateTime updatedAt = DateTime(2026, 3, 11, 12);
      expect(
        debugIOS17HeaderLastUpdatedText(
          updatedAt: updatedAt,
          builder: (_) => 'Synced moments ago',
        ),
        'Synced moments ago',
      );
    });
  });

  group('iOS17Header widget', () {
    testWidgets('renders without error in Cupertino theme', (WidgetTester tester) async {
      final RefreshController controller = RefreshController();
      await tester.pumpWidget(_refresherHarness(
        controller: controller,
        header: const iOS17Header(),
      ));

      expect(tester.takeException(), isNull);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('uses RefreshStyle.Follow by default', (WidgetTester tester) async {
      const iOS17Header header = iOS17Header();
      expect(header.refreshStyle, RefreshStyle.Follow);
    });

    testWidgets('color prop overrides theme', (WidgetTester tester) async {
      const Color customColor = CupertinoColors.activeBlue;
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: IOS17ActivityIndicator(
            color: customColor,
            radius: 10.0,
            progress: 1.0,
            gradientOpacity: 0.0,
          ),
        ),
      );

      final CustomPaint customPaint =
          tester.widget<CustomPaint>(find.byType(CustomPaint));
      expect(customPaint.painter, isNotNull);
      expect(
        (customPaint.painter! as dynamic).color,
        customColor,
      );
    });

    testWidgets('custom painter draws zero ticks at progress 0.0',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: IOS17ActivityIndicator(
            color: CupertinoColors.activeBlue,
            radius: 10.0,
            progress: 0.0,
          ),
        ),
      );

      expect(
        tester.renderObject(find.byType(CustomPaint)),
        paintsExactlyCountTimes(#drawRRect, 0),
      );
    });

    testWidgets('custom painter draws six ticks at progress 0.5',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: IOS17ActivityIndicator(
            color: CupertinoColors.activeBlue,
            radius: 10.0,
            progress: 0.5,
          ),
        ),
      );

      expect(
        tester.renderObject(find.byType(CustomPaint)),
        paintsExactlyCountTimes(#drawRRect, 6),
      );
    });

    testWidgets('custom painter draws twelve ticks at progress 1.0',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: IOS17ActivityIndicator(
            color: CupertinoColors.activeBlue,
            radius: 10.0,
            progress: 1.0,
          ),
        ),
      );

      expect(
        tester.renderObject(find.byType(CustomPaint)),
        paintsExactlyCountTimes(#drawRRect, 12),
      );
    });

    testWidgets('adapts in dark mode with Cupertino dynamic colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (BuildContext context) {
                return const IOS17ActivityIndicator(
                  color: CupertinoColors.systemFill,
                  radius: 10.0,
                  progress: 1.0,
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(IOS17ActivityIndicator), findsOneWidget);
    });

    testWidgets('records completion timestamp on completion', (WidgetTester tester) async {
      final GlobalKey<iOS17HeaderState> key = GlobalKey<iOS17HeaderState>();
      final RefreshController controller = RefreshController();

      await tester.pumpWidget(_refresherHarness(
        controller: controller,
        header: iOS17Header(key: key, showLastUpdated: true),
      ));

      controller.requestRefresh(needMove: false);
      await tester.pump();
      key.currentState!.debugSetVisualMode(RefreshStatus.completed);
      await tester.pump();

      expect(key.currentState!.debugLastUpdatedAt, isNotNull);
    });

    testWidgets('default configuration hides timestamp text option', (WidgetTester tester) async {
      const iOS17Header header = iOS17Header();
      expect(header.showLastUpdated, isFalse);
    });

    testWidgets('scale pop starts when threshold is crossed', (WidgetTester tester) async {
      final GlobalKey<iOS17HeaderState> key = GlobalKey<iOS17HeaderState>();
      final RefreshController controller = RefreshController();

      await tester.pumpWidget(_refresherHarness(
        controller: controller,
        header: iOS17Header(key: key),
      ));

      controller.requestRefresh(needMove: false);
      await tester.pump();
      key.currentState!.debugStartScalePop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(key.currentState!.debugScaleControllerValue, greaterThan(0.0));
    });

    testWidgets('opacity controller runs on refreshing', (WidgetTester tester) async {
      final GlobalKey<iOS17HeaderState> key = GlobalKey<iOS17HeaderState>();
      final RefreshController controller = RefreshController();

      await tester.pumpWidget(_refresherHarness(
        controller: controller,
        header: iOS17Header(key: key),
      ));

      controller.requestRefresh(needMove: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(key.currentState!.debugOpacityControllerValue, greaterThan(0.0));
    });

    testWidgets('dismiss controller runs for fixed 300ms', (WidgetTester tester) async {
      final GlobalKey<iOS17HeaderState> key = GlobalKey<iOS17HeaderState>();
      final RefreshController controller = RefreshController();

      await tester.pumpWidget(_refresherHarness(
        controller: controller,
        header: iOS17Header(key: key),
      ));

      controller.requestRefresh(needMove: false);
      await tester.pump();
      key.currentState!.debugStartDismissAnimation();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(key.currentState!.debugDismissControllerValue, greaterThan(0.0));
      expect(key.currentState!.debugDismissControllerValue, lessThan(1.0));

      await tester.pump(const Duration(milliseconds: 150));

      expect(key.currentState!.debugDismissControllerValue, 1.0);
    });

    testWidgets(
        'fires medium haptic once on iOS refresh',
        (WidgetTester tester) async {
      final GlobalKey<iOS17HeaderState> key = GlobalKey<iOS17HeaderState>();
      final RefreshController controller = RefreshController();
      final List<MethodCall> calls = <MethodCall>[];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
        calls.add(call);
        return null;
      });

      await tester.pumpWidget(_refresherHarness(
        controller: controller,
        header: iOS17Header(key: key),
      ));

      key.currentState!.debugSetVisualMode(RefreshStatus.refreshing);
      key.currentState!.debugSetVisualMode(RefreshStatus.refreshing);
      await tester.pump();

      expect(
        calls.where((MethodCall call) => call.method == 'HapticFeedback.vibrate').length,
        1,
      );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('dispose during animation does not throw', (WidgetTester tester) async {
      final GlobalKey<iOS17HeaderState> key = GlobalKey<iOS17HeaderState>();
      final RefreshController controller = RefreshController();

      await tester.pumpWidget(_refresherHarness(
        controller: controller,
        header: iOS17Header(key: key),
      ));

      controller.requestRefresh(needMove: false);
      await tester.pump(const Duration(milliseconds: 50));

      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _refresherHarness({
  required RefreshController controller,
  required Widget header,
}) {
  return CupertinoApp(
    home: CupertinoPageScaffold(
      child: SmartRefresher(
        controller: controller,
        header: header,
        onRefresh: () {},
        child: ListView.builder(
          itemCount: 20,
          itemBuilder: (BuildContext context, int index) =>
              SizedBox(height: 80.0, child: Text('Item $index')),
        ),
      ),
    ),
  );
}
