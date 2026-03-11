import 'package:flutter/material.dart' hide RefreshIndicator;
import 'package:smart_refresher/smart_refresher.dart';

import '../../main.dart';
import '../../theme/app_theme.dart';
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

  IndicatorResolution _resolutionFor(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SmartRefresherThemeData refresherTheme =
        SmartRefresherThemeData.fallback(context);
    final IndicatorThemeData? widgetTheme = _mode == _ThemingMode.custom
        ? IndicatorThemeData(
            primaryColor: theme.colorScheme.tertiary,
            trackColor: theme.colorScheme.tertiaryContainer,
            containerColor: theme.colorScheme.surfaceContainerHigh,
            textStyle: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.tertiary,
            ),
          )
        : null;
    return switch (_indicator) {
      _ThemingIndicator.classic => resolveIndicatorTheme(
          context,
          widgetTheme: widgetTheme,
          themedDefaults: refresherTheme.classicHeader,
          schemePrimary: theme.colorScheme.primary,
          schemeTrack: theme.colorScheme.surfaceContainerHighest,
          schemeContainer: theme.colorScheme.surface,
        ),
      _ThemingIndicator.material3 => resolveIndicatorTheme(
          context,
          widgetTheme: widgetTheme,
          themedDefaults: refresherTheme.material3Header,
          schemePrimary: theme.colorScheme.primary,
          schemeTrack: theme.colorScheme.surfaceContainerHighest,
          schemeContainer: theme.colorScheme.surfaceContainerLow,
        ),
      _ThemingIndicator.ios17 => resolveIndicatorTheme(
          context,
          widgetTheme: widgetTheme,
          themedDefaults: refresherTheme.ios17Header,
          schemePrimary: theme.colorScheme.primary,
          schemeTrack: theme.colorScheme.surfaceContainerHighest,
          schemeContainer: theme.colorScheme.surface,
        ),
    };
  }

  RefreshIndicator _buildHeader(
    BuildContext context,
    IndicatorResolution resolution,
  ) {
    return switch (_indicator) {
      _ThemingIndicator.classic => ClassicHeader(
          textStyle: resolution.data.textStyle.copyWith(
            color: resolution.data.primaryColor,
          ),
          idleIcon: Icon(
            Icons.arrow_downward_rounded,
            color: resolution.data.primaryColor,
          ),
          releaseIcon: Icon(
            Icons.refresh_rounded,
            color: resolution.data.primaryColor,
          ),
          completeIcon: Icon(
            Icons.check_rounded,
            color: resolution.data.primaryColor,
          ),
          refreshingIcon: SizedBox(
            width: 18.0,
            height: 18.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: resolution.data.primaryColor,
            ),
          ),
        ),
      _ThemingIndicator.material3 => Material3Header(
          color: resolution.data.primaryColor,
          backgroundColor: resolution.data.containerColor,
        ),
      _ThemingIndicator.ios17 => iOS17Header(
          color: resolution.data.primaryColor,
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
    final IndicatorResolution resolution = _resolutionFor(context);
    final DemoAppStateScope scope = DemoAppStateScope.of(context);
    final ThemeData themedWrapper = _mode == _ThemingMode.custom
        ? Theme.of(context).copyWith(
            extensions: <ThemeExtension<dynamic>>[
              SmartRefresherThemeData.fallback(context).copyWith(
                classicHeader: IndicatorThemeData(
                  primaryColor: Theme.of(context).colorScheme.tertiary,
                  trackColor: Theme.of(context).colorScheme.tertiaryContainer,
                  containerColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHigh,
                  textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                ),
                material3Header: IndicatorThemeData(
                  primaryColor: Theme.of(context).colorScheme.tertiary,
                  containerColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHigh,
                ),
                ios17Header: IndicatorThemeData(
                  primaryColor: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          )
        : Theme.of(context);

    return Theme(
      data: themedWrapper,
      child: Scaffold(
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
      ),
    );
  }
}

class _ResolutionTracePanel extends StatelessWidget {
  const _ResolutionTracePanel({required this.resolution});

  final IndicatorResolution resolution;

  String _hex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Resolution Trace',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12.0),
              _TraceRow(
                label: 'primaryColor',
                color: resolution.data.primaryColor,
                source: resolution.trace['primaryColor']!,
                value: _hex(resolution.data.primaryColor),
              ),
              _TraceRow(
                label: 'trackColor',
                color: resolution.data.trackColor,
                source: resolution.trace['trackColor']!,
                value: _hex(resolution.data.trackColor),
              ),
              _TraceRow(
                label: 'containerColor',
                color: resolution.data.containerColor,
                source: resolution.trace['containerColor']!,
                value: _hex(resolution.data.containerColor),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('textStyle'),
                subtitle: Text(resolution.trace['textStyle']!),
                trailing: Text(
                  '${resolution.data.textStyle.fontSize?.toStringAsFixed(0) ?? '13'} px',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TraceRow extends StatelessWidget {
  const _TraceRow({
    required this.label,
    required this.color,
    required this.source,
    required this.value,
  });

  final String label;
  final Color color;
  final String source;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(source),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 18.0,
            height: 18.0,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          const SizedBox(width: 8.0),
          Text(value),
        ],
      ),
    );
  }
}
