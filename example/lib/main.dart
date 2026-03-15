import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:iconify_sdk/iconify_sdk.dart';

import 'app_router.dart';
import 'screens/footers/classic_footer_screen.dart';
import 'screens/footers/footer_comparison_screen.dart';
import 'screens/footers/skeleton_footer_screen.dart';
import 'screens/headers/classic_header_screen.dart';
import 'screens/headers/header_comparison_screen.dart';
import 'screens/headers/ios17_header_screen.dart';
import 'screens/elastic_header_screen.dart';
import 'ui/example/glass_header_example.dart';
import 'screens/headers/material3_header_screen.dart';
import 'screens/home_screen.dart';
import 'screens/theming/theming_screen.dart';
import 'integrations/riverpod_example.dart';
import 'integrations/bloc_example.dart';
import 'integrations/provider_example.dart';
import 'integrations/builder_slots_example.dart';
import 'theme/app_theme.dart';

void main() {
  enableFlutterDriverExtension();
  runApp(const IconifyApp(child: SmartRefresherDemoApp()));
}

class SmartRefresherDemoApp extends StatefulWidget {
  const SmartRefresherDemoApp({super.key});

  @override
  State<SmartRefresherDemoApp> createState() => _SmartRefresherDemoAppState();
}

class _SmartRefresherDemoAppState extends State<SmartRefresherDemoApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Color _seedColor = Colors.deepPurple;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _setSeedColor(Color color) {
    setState(() {
      _seedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DemoAppStateScope(
      themeMode: _themeMode,
      seedColor: _seedColor,
      toggleTheme: _toggleTheme,
      setSeedColor: _setSeedColor,
      child: MaterialApp(
        title: 'smart_refresher demo',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: AppTheme.light(_seedColor),
        darkTheme: AppTheme.dark(_seedColor),
        initialRoute: AppRoutes.home,
        routes: <String, WidgetBuilder>{
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.classicHeader: (_) => const ClassicHeaderScreen(),
          AppRoutes.material3Header: (_) => const Material3HeaderScreen(),
          AppRoutes.ios17Header: (_) => const Ios17HeaderScreen(),
          AppRoutes.glassHeader: (_) => const GlassHeaderExample(),
          AppRoutes.elasticHeader: (_) => const ElasticHeaderScreen(),
          AppRoutes.headerCompare: (_) => const HeaderComparisonScreen(),
          AppRoutes.classicFooter: (_) => const ClassicFooterScreen(),
          AppRoutes.skeletonFooter: (_) => const SkeletonFooterScreen(),
          AppRoutes.footerCompare: (_) => const FooterComparisonScreen(),
          AppRoutes.theming: (_) => const ThemingScreen(),
          AppRoutes.riverpod: (_) => const RiverpodExample(),
          AppRoutes.bloc: (_) => const BlocExample(),
          AppRoutes.provider: (_) => const ProviderExample(),
          AppRoutes.builderSlots: (_) => const BuilderSlotsExample(),
        },
      ),
    );
  }
}

class DemoAppStateScope extends InheritedWidget {
  const DemoAppStateScope({
    super.key,
    required this.themeMode,
    required this.seedColor,
    required this.toggleTheme,
    required this.setSeedColor,
    required super.child,
  });

  final ThemeMode themeMode;
  final Color seedColor;
  final VoidCallback toggleTheme;
  final ValueChanged<Color> setSeedColor;

  static DemoAppStateScope of(BuildContext context) {
    final DemoAppStateScope? scope =
        context.dependOnInheritedWidgetOfExactType<DemoAppStateScope>();
    assert(scope != null, 'DemoAppStateScope is missing in the widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(DemoAppStateScope oldWidget) {
    return themeMode != oldWidget.themeMode || seedColor != oldWidget.seedColor;
  }
}

class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final DemoAppStateScope scope = DemoAppStateScope.of(context);
    final bool isDark = scope.themeMode == ThemeMode.dark;
    return IconButton(
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      onPressed: scope.toggleTheme,
      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
    );
  }
}
