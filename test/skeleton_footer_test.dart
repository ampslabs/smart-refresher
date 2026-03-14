import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';
import 'package:smart_refresher/src/internals/slivers.dart';

void main() {
  group('SkeletonFooter', () {
    test('defaults to ShowWhenLoading', () {
      expect(const SkeletonFooter().loadStyle, LoadStyle.showWhenLoading);
    });

    test('asserts for skeletonCount below range', () {
      expect(() => SkeletonFooter(skeletonCount: 0), throwsAssertionError);
    });

    test('asserts for skeletonCount above range', () {
      expect(() => SkeletonFooter(skeletonCount: 6), throwsAssertionError);
    });

    testWidgets('renders default list tile layout during loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestHarness(initialLoadStatus: LoadStatus.loading),
      );
      await tester.pump();

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(BoneListTile), findsNWidgets(3));
      expect(find.byType(ShimmerLoading), findsNWidgets(3));
    });

    testWidgets('idle state renders no shimmer', (WidgetTester tester) async {
      await tester.pumpWidget(const _TestHarness());

      expect(find.byType(Shimmer), findsNothing);
      expect(find.byType(BoneListTile), findsNothing);
      expect(_footerLayoutExtent(tester), 0.0);
    });

    testWidgets('canLoading state renders no shimmer', (
      WidgetTester tester,
    ) async {
      final RefreshController controller = RefreshController();
      await tester.pumpWidget(_TestHarness(controller: controller));
      controller.footerMode!.value = LoadStatus.canLoading;
      await tester.pump();

      expect(find.byType(Shimmer), findsNothing);
      expect(_footerLayoutExtent(tester), 0.0);
    });

    testWidgets('noMore state renders no shimmer', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestHarness(initialLoadStatus: LoadStatus.noMore),
      );

      expect(find.byType(Shimmer), findsNothing);
      expect(_footerLayoutExtent(tester), 0.0);
    });

    testWidgets('failed state renders no shimmer', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestHarness(initialLoadStatus: LoadStatus.failed),
      );

      expect(find.byType(Shimmer), findsNothing);
      expect(_footerLayoutExtent(tester), 0.0);
    });

    testWidgets('fade-in starts when loading begins', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestHarness(initialLoadStatus: LoadStatus.loading),
      );
      final SkeletonFooterState state = tester.state<SkeletonFooterState>(
        find.byType(SkeletonFooter),
      );

      expect(state.fadeController.value, 0.0);
      await tester.pump(const Duration(milliseconds: 80));
      expect(state.fadeController.value, greaterThan(0.0));
    });

    testWidgets('fade-out starts when loading completes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestHarness(initialLoadStatus: LoadStatus.loading),
      );
      await tester.pump(const Duration(milliseconds: 200));
      final SkeletonFooterState state = tester.state<SkeletonFooterState>(
        find.byType(SkeletonFooter),
      );
      final double loadedValue = state.fadeController.value;

      state.endLoading();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));

      expect(state.fadeController.value, lessThan(loadedValue));
    });

    testWidgets('skeletonCount 1 renders one loading row', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestHarness(
          initialLoadStatus: LoadStatus.loading,
          footer: SkeletonFooter(skeletonCount: 1),
        ),
      );
      await tester.pump();

      expect(find.byType(ShimmerLoading), findsOneWidget);
    });

    testWidgets('skeletonCount 5 renders five loading rows', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestHarness(
          initialLoadStatus: LoadStatus.loading,
          footer: SkeletonFooter(skeletonCount: 5, height: 280.0),
        ),
      );
      await tester.pump();

      expect(find.byType(ShimmerLoading), findsNWidgets(5));
    });

    testWidgets('card layout renders BoneCard', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestHarness(
          initialLoadStatus: LoadStatus.loading,
          footer: SkeletonFooter(
            boneStyle: SkeletonBoneStyle.card,
            skeletonCount: 2,
            height: 260.0,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(BoneCard), findsNWidgets(2));
    });

    testWidgets('text block layout renders BoneTextBlock', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestHarness(
          initialLoadStatus: LoadStatus.loading,
          footer: SkeletonFooter(boneStyle: SkeletonBoneStyle.textBlock),
        ),
      );
      await tester.pump();

      expect(find.byType(BoneTextBlock), findsNWidgets(3));
    });

    testWidgets('image row layout renders BoneImageRow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestHarness(
          initialLoadStatus: LoadStatus.loading,
          footer: SkeletonFooter(boneStyle: SkeletonBoneStyle.imageRow),
        ),
      );
      await tester.pump();

      expect(find.byType(BoneImageRow), findsNWidgets(3));
    });

    testWidgets('boneBuilder overrides preset style', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _TestHarness(
          initialLoadStatus: LoadStatus.loading,
          footer: SkeletonFooter(
            boneBuilder: (BuildContext context, int index) {
              return Text('custom-$index', textDirection: TextDirection.ltr);
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('custom-0'), findsOneWidget);
      expect(find.byType(BoneListTile), findsNothing);
    });

    testWidgets('shimmer loading uses ShaderMask with srcATop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestHarness(initialLoadStatus: LoadStatus.loading),
      );
      await tester.pump();

      final ShaderMask shaderMask = tester.widget<ShaderMask>(
        find.byType(ShaderMask).first,
      );
      expect(shaderMask.blendMode, BlendMode.srcATop);
    });

    testWidgets('light theme uses light shimmer gradient', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _TestHarness(
          initialLoadStatus: LoadStatus.loading,
          theme: ThemeData.light(),
        ),
      );
      await tester.pump();

      final ShimmerState state = tester.state<ShimmerState>(
        find.byType(Shimmer),
      );
      expect(state.gradient.colors, const <Color>[
        Color(0xFFEBEBF4),
        Color(0xFFF4F4F4),
        Color(0xFFEBEBF4),
      ]);
    });

    testWidgets('dark theme uses dark shimmer gradient', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _TestHarness(
          initialLoadStatus: LoadStatus.loading,
          theme: ThemeData.dark(),
        ),
      );
      await tester.pump();

      final ShimmerState state = tester.state<ShimmerState>(
        find.byType(Shimmer),
      );
      expect(state.gradient.colors, const <Color>[
        Color(0xFF2A2A2A),
        Color(0xFF3A3A3A),
        Color(0xFF2A2A2A),
      ]);
    });

    testWidgets('custom shimmer gradient is respected', (
      WidgetTester tester,
    ) async {
      const LinearGradient customGradient = LinearGradient(
        colors: <Color>[Colors.red, Colors.blue, Colors.red],
        stops: <double>[0.2, 0.5, 0.8],
      );
      await tester.pumpWidget(
        const _TestHarness(
          initialLoadStatus: LoadStatus.loading,
          footer: SkeletonFooter(shimmerGradient: customGradient),
        ),
      );
      await tester.pump();

      final ShimmerState state = tester.state<ShimmerState>(
        find.byType(Shimmer),
      );
      expect(state.gradient.colors, customGradient.colors);
      expect(state.gradient.stops, customGradient.stops);
    });

    testWidgets('dispose during loading does not throw', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestHarness(initialLoadStatus: LoadStatus.loading),
      );
      await tester.pump(const Duration(milliseconds: 40));
      await tester.pumpWidget(const SizedBox.shrink());

      expect(tester.takeException(), isNull);
    });

    testWidgets('staggered variant uses sequential fade transitions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestHarness(
          initialLoadStatus: LoadStatus.loading,
          footer: SkeletonFooter.staggered(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      final SkeletonFooterState state = tester.state<SkeletonFooterState>(
        find.byType(SkeletonFooter),
      );

      final List<FadeTransition> fades =
          tester.widgetList<FadeTransition>(find.byType(FadeTransition)).where((
        FadeTransition fade,
      ) {
        final Animation<double> opacity = fade.opacity;
        return opacity is CurvedAnimation &&
            opacity.parent == state.fadeAnimation;
      }).toList();
      expect(fades, hasLength(3));
      expect(fades[0].opacity.value, greaterThan(fades[1].opacity.value));
      expect(fades[1].opacity.value, greaterThan(fades[2].opacity.value));
    });
  });

  group('SkeletonFooter goldens', () {
    testWidgets('list tile light', (WidgetTester tester) async {
      await _pumpGolden(
        tester,
        style: SkeletonBoneStyle.listTile,
        theme: ThemeData.light(),
      );
      await expectLater(
        find.byKey(_goldenKey),
        matchesGoldenFile('goldens/skeleton_footer_list_tile_light.png'),
      );
    });

    testWidgets('list tile dark', (WidgetTester tester) async {
      await _pumpGolden(
        tester,
        style: SkeletonBoneStyle.listTile,
        theme: ThemeData.dark(),
      );
      await expectLater(
        find.byKey(_goldenKey),
        matchesGoldenFile('goldens/skeleton_footer_list_tile_dark.png'),
      );
    });

    testWidgets('card light', (WidgetTester tester) async {
      await _pumpGolden(
        tester,
        style: SkeletonBoneStyle.card,
        theme: ThemeData.light(),
        skeletonCount: 2,
      );
      await expectLater(
        find.byKey(_goldenKey),
        matchesGoldenFile('goldens/skeleton_footer_card_light.png'),
      );
    });

    testWidgets('card dark', (WidgetTester tester) async {
      await _pumpGolden(
        tester,
        style: SkeletonBoneStyle.card,
        theme: ThemeData.dark(),
        skeletonCount: 2,
      );
      await expectLater(
        find.byKey(_goldenKey),
        matchesGoldenFile('goldens/skeleton_footer_card_dark.png'),
      );
    });

    testWidgets('text block light', (WidgetTester tester) async {
      await _pumpGolden(
        tester,
        style: SkeletonBoneStyle.textBlock,
        theme: ThemeData.light(),
      );
      await expectLater(
        find.byKey(_goldenKey),
        matchesGoldenFile('goldens/skeleton_footer_text_block_light.png'),
      );
    });

    testWidgets('text block dark', (WidgetTester tester) async {
      await _pumpGolden(
        tester,
        style: SkeletonBoneStyle.textBlock,
        theme: ThemeData.dark(),
      );
      await expectLater(
        find.byKey(_goldenKey),
        matchesGoldenFile('goldens/skeleton_footer_text_block_dark.png'),
      );
    });

    testWidgets('image row light', (WidgetTester tester) async {
      await _pumpGolden(
        tester,
        style: SkeletonBoneStyle.imageRow,
        theme: ThemeData.light(),
        skeletonCount: 2,
      );
      await expectLater(
        find.byKey(_goldenKey),
        matchesGoldenFile('goldens/skeleton_footer_image_row_light.png'),
      );
    });

    testWidgets('image row dark', (WidgetTester tester) async {
      await _pumpGolden(
        tester,
        style: SkeletonBoneStyle.imageRow,
        theme: ThemeData.dark(),
        skeletonCount: 2,
      );
      await expectLater(
        find.byKey(_goldenKey),
        matchesGoldenFile('goldens/skeleton_footer_image_row_dark.png'),
      );
    });
  });
}

const Key _goldenKey = Key('skeleton-footer-golden');

class _TestHarness extends StatelessWidget {
  const _TestHarness({
    this.controller,
    this.footer,
    this.initialLoadStatus = LoadStatus.idle,
    this.theme,
  });

  final RefreshController? controller;
  final SkeletonFooter? footer;
  final LoadStatus initialLoadStatus;
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final RefreshController effectiveController =
        controller ?? RefreshController(initialLoadStatus: initialLoadStatus);
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: SmartRefresher(
          controller: effectiveController,
          enablePullUp: true,
          footer: footer ?? const SkeletonFooter(),
          child: ListView.builder(
            itemCount: 20,
            itemExtent: 72.0,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(title: Text('Item $index'));
            },
          ),
        ),
      ),
    );
  }
}

Future<void> _pumpGolden(
  WidgetTester tester, {
  required SkeletonBoneStyle style,
  required ThemeData theme,
  int skeletonCount = 3,
}) async {
  await tester.binding.setSurfaceSize(const Size(430.0, 932.0));
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: RepaintBoundary(
            key: _goldenKey,
            child: SizedBox(
              width: 390.0,
              child: ColoredBox(
                color: theme.scaffoldBackgroundColor,
                child: Shimmer(
                  slidePercent: 0.4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(skeletonCount, (
                      int index,
                    ) {
                      return ShimmerLoading(
                        isLoading: true,
                        child: _goldenBone(style, index),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Widget _goldenBone(SkeletonBoneStyle style, int index) {
  switch (style) {
    case SkeletonBoneStyle.listTile:
      return const BoneListTile();
    case SkeletonBoneStyle.card:
      return const BoneCard();
    case SkeletonBoneStyle.textBlock:
      return const BoneTextBlock();
    case SkeletonBoneStyle.imageRow:
      return const BoneImageRow();
  }
}

double _footerLayoutExtent(WidgetTester tester) {
  final RenderSliverLoading renderSliver =
      tester.renderObject<RenderSliverLoading>(
    find.byType(SliverLoading),
  );
  return renderSliver.geometry?.layoutExtent ?? 0.0;
}
