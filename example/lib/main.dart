import 'package:example/other/refresh_glowindicator.dart';
import 'package:example/ui/MainActivity.dart';
import 'package:example/ui/SecondActivity.dart';
import 'package:example/ui/example/skeleton_footer_example.dart';
import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';
import 'ui/indicator/base/IndicatorActivity.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const MyApp());

/// The example application entry widget.
class MyApp extends StatelessWidget {
  /// Creates the example application root.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      dragSpeedRatio: 0.91,
      headerBuilder: () => const MaterialClassicHeader(),
      footerBuilder: () => const ClassicFooter(),
      shouldFooterFollowWhenNotFull: (state) {
        return false;
      },
      child: MaterialApp(
        title: 'Pulltorefresh Demo',
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: RefreshScrollBehavior(),
            child: child!,
          );
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.greenAccent,
        ),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          RefreshLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[
          Locale('en'),
          Locale('zh'),
          Locale('ja'),
          Locale('uk'),
          Locale('it'),
          Locale('ru'),
          Locale('fr'),
          Locale('es'),
          Locale('nl'),
          Locale('sv'),
          Locale('pt'),
          Locale('ko'),
        ],
        locale: const Locale('zh'),
        localeResolutionCallback:
            (Locale? locale, Iterable<Locale> supportedLocales) {
          return locale;
        },
        home: const MainActivity(title: 'Pulltorefresh'),
        routes: <String, WidgetBuilder>{
          'sec': (BuildContext context) {
            return const SecondActivity(
              title: 'SecondAct',
            );
          },
          'indicator': (BuildContext context) {
            return const IndicatorActivity(title: 'Indicators');
          },
          'skeleton-footer': (BuildContext context) {
            return const SkeletonFooterExamplePage();
          },
        },
      ),
    );
  }
}
