/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/3 6:13 PM
 */

import 'package:flutter/material.dart';
import 'example/ExamplePage.dart';
import 'test/TestPage.dart';
import 'indicator/IndicatorPage.dart';

class MainActivity extends StatefulWidget {
  final String? title;

  const MainActivity({this.title, super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainActivityState();
  }
}

class _MainActivityState extends State<MainActivity>
    with TickerProviderStateMixin {
  late List<Widget> views;
  late TabController _tabController;
  int _tabIndex = 1;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _pageController = PageController(initialPage: 1);
    views = [
      const IndicatorPage(title: "Indicators"),
      const ExamplePage(),
      const TestPage(title: "Tests"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabIndex == 0
            ? "Indicators"
            : _tabIndex == 1
                ? "Examples"
                : _tabIndex == 2
                    ? "Tests"
                    : _tabIndex == 3
                        ? "Samples"
                        : "App"),
        backgroundColor: Colors.greenAccent,
        bottom: _tabIndex == 3
            ? TabBar(
                isScrollable: true,
                tabs: const [
                  Tab(child: Text("Large Data Performance")),
                  Tab(child: Text("SliverAppbar+Sliverheader")),
                  Tab(child: Text("NestedScrollView")),
                  Tab(child: Text("Dynamic Indicator+Navigator")),
                  Tab(child: Text("Active Refresh")),
                  Tab(child: Text("Four Directions Test")),
                ],
                controller: _tabController,
              )
            : null,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("Jpeng"),
              accountEmail: Text("peng8350@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://avatars1.githubusercontent.com/u/19425362?s=400&u=1a30f9fdf71cc9a51e20729b2fa1410c710d0f2f&v=4'),
              ),
              decoration: BoxDecoration(color: Colors.greenAccent),
            ),
            ListTile(
              title: const Text("Indicators"),
              leading: const Icon(Icons.apps, color: Colors.grey),
              onTap: () {
                setState(() {
                  _tabIndex = 0;
                });
                _pageController.jumpToPage(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Examples"),
              leading: const Icon(Icons.insert_emoticon, color: Colors.grey),
              onTap: () {
                setState(() {
                  _tabIndex = 1;
                });
                _pageController.jumpToPage(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Tests"),
              leading: const Icon(Icons.airplanemode_active, color: Colors.grey),
              onTap: () {
                setState(() {
                  _tabIndex = 2;
                });
                _pageController.jumpToPage(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: views,
      ),
    );
  }
}
