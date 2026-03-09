/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/3 下午6:13
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
      IndicatorPage(title: "指示器界面"),
      ExamplePage(),
      TestPage(title: "测试界面"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabIndex == 0
            ? "指示器界面"
            : _tabIndex == 1
                ? "例子界面"
                : _tabIndex == 2
                    ? "测试界面"
                    : _tabIndex == 3
                        ? "样例界面"
                        : "App界面"),
        backgroundColor: Colors.greenAccent,
        bottom: _tabIndex == 3
            ? TabBar(
                isScrollable: true,
                tabs: [
                  Tab(child: Text("超大数据量性能测试")),
                  Tab(child: Text("SliverAppbar+Sliverheader")),
                  Tab(child: Text("嵌套滚动视图")),
                  Tab(child: Text("动态变化指示器+Navigator")),
                  Tab(child: Text("主动刷新")),
                  Tab(child: Text("四个方向不同风格测试绘制")),
                ],
                controller: _tabController,
              )
            : null,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Jpeng"),
              accountEmail: Text("peng8350@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://avatars1.githubusercontent.com/u/19425362?s=400&u=1a30f9fdf71cc9a51e20729b2fa1410c710d0f2f&v=4'),
              ),
              decoration: BoxDecoration(color: Colors.greenAccent),
            ),
            ListTile(
              title: Text("各种指示器"),
              leading: Icon(Icons.apps, color: Colors.grey),
              onTap: () {
                setState(() {
                  _tabIndex = 0;
                });
                _pageController.jumpToPage(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("例子"),
              leading: Icon(Icons.insert_emoticon, color: Colors.grey),
              onTap: () {
                setState(() {
                  _tabIndex = 1;
                });
                _pageController.jumpToPage(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("测试"),
              leading: Icon(Icons.airplanemode_active, color: Colors.grey),
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
        physics: NeverScrollableScrollPhysics(),
        children: views,
      ),
    );
  }
}
