import 'package:flutter/material.dart' hide RefreshIndicator;
import 'package:smart_refresher/smart_refresher.dart';

import '../../main.dart';
import '../../widgets/fake_list_item.dart';
import '../../widgets/indicator_chip_selector.dart';

enum _ThemingIndicator { classic, material3, ios17 }

enum _ThemingMode { zeroConfig, custom }

class ThemingScreen extends StatefulWidget {
  const ThemingScreen({super.key});

  @override
  State<ThemingScreen> createState() => _ThemingScreenState();
}

class _ThemingScreenState extends State<ThemingScreen> {
  late RefreshController _controller;
  _ThemingIndicator _indicator = _ThemingIndicator.classic;
  _ThemingMode _mode = _ThemingMode.zeroConfig;
  List<int> _items = List<int>.generate(16, (int index) => index + 1);

  @override
  void initState() {
    super.initState();
    _controller = RefreshController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IndicatorThemeData _resolutionFor(BuildContext context) {
    return IndicatorThemeData.resolve(context);
  }

  RefreshIndicator _buildHeader(
    BuildContext context,
    IndicatorThemeData resolution,
  ) {
    return switch (_indicator) {
      _ThemingIndicator.classic => ClassicHeader(
          textStyle: resolution.textStyle.copyWith(
            color: resolution.primaryColor,
          ),
          idleIcon: Icon(
            Icons.arrow_downward_rounded,
            color: resolution.primaryColor,
          ),
          releaseIcon: Icon(
            Icons.refresh_rounded,
            color: resolution.primaryColor,
          ),
          completeIcon: Icon(
            Icons.check_rounded,
            color: resolution.primaryColor,
          ),
          refreshingIcon: SizedBox(
            width: 18.0,
            height: 18.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: resolution.primaryColor,
            ),
          ),
        ),
      _ThemingIndicator.material3 => const Material3Header(),
      _ThemingIndicator.ios17 => const iOS17Header(
          showLastUpdated: true,
        ),
    };
  }

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }
    setState(() {
      _items = List<int>.generate(16, (int index) => index + 1);
    });
    _controller.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final DemoAppStateScope scope = DemoAppStateScope.of(context);
    final ThemeData themedWrapper = _mode == _ThemingMode.custom
        ? Theme.of(context).copyWith(
            extensions: <ThemeExtension<dynamic>>[
              SmartRefresherThemeData(
                primaryColor: Theme.of(context).colorScheme.tertiary,
                trackColor: Theme.of(context).colorScheme.tertiaryContainer,
                material3BackgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHigh,
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                iosTickColor: Theme.of(context).colorScheme.tertiary,
              ),
            ],
          )
        : Theme.of(context);

    return Theme(
      data: themedWrapper,
      child: Builder(builder: (context) {
        final IndicatorThemeData resolution = _resolutionFor(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Theming Demo'),
            actions: const <Widget>[ThemeModeToggle()],
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'SEED COLOR',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8.0),
                        Wrap(
                          spacing: 8.0,
                          children: <(String, Color)>[
                            ('Purple', Colors.deepPurple),
                            ('Teal', Colors.teal),
                            ('Orange', Colors.orange),
                          ].map(((String, Color) entry) {
                            final (String label, Color color) = entry;
                            return ChoiceChip(
                              label: Text(label),
                              selected: scope.seedColor == color,
                              onSelected: (_) => scope.setSeedColor(color),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          'INDICATOR',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        IndicatorChipSelector<_ThemingIndicator>(
                          options: const <(String, _ThemingIndicator)>[
                            ('Classic', _ThemingIndicator.classic),
                            ('M3', _ThemingIndicator.material3),
                            ('iOS', _ThemingIndicator.ios17),
                          ],
                          selected: _indicator,
                          onSelected: (_ThemingIndicator value) =>
                              setState(() => _indicator = value),
                        ),
                        Text(
                          'MODE',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        IndicatorChipSelector<_ThemingMode>(
                          options: const <(String, _ThemingMode)>[
                            ('Zero-config', _ThemingMode.zeroConfig),
                            ('Custom', _ThemingMode.custom),
                          ],
                          selected: _mode,
                          onSelected: (_ThemingMode value) =>
                              setState(() => _mode = value),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _ResolutionTracePanel(resolution: resolution),
              Expanded(
                child: SmartRefresher(
                  controller: _controller,
                  header: _buildHeader(context, resolution),
                  footer: const SkeletonFooter(),
                  enablePullUp: true,
                  onRefresh: _onRefresh,
                  onLoading: () async => _controller.loadComplete(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    itemCount: _items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return FakeListItem(index: _items[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ResolutionTracePanel extends StatelessWidget {
  const _ResolutionTracePanel({required this.resolution});

  final IndicatorThemeData resolution;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: resolution.trackColor.withValues(alpha: 0.1),
      child: Row(
        children: <Widget>[
          Icon(Icons.info_outline_rounded, size: 16.0, color: resolution.primaryColor),
          const SizedBox(width: 8.0),
          Text(
            'Resolution: ${resolution.primaryColor.toString().toUpperCase()}',
            style: resolution.textStyle.copyWith(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

