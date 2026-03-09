/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-24 5:14 PM
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

/*
  This example demonstrates how to use a vertical PageView as a child in SmartRefresher.
 */
class PageViewExample extends StatefulWidget {
  const PageViewExample({super.key});

  @override
  PageViewExampleState createState() => PageViewExampleState();
}

class PageViewExampleState extends State<PageViewExample>
    with TickerProviderStateMixin {
  late RefreshController _refreshController;
  int _lastReportedPage = 0;
  List<Widget> data = [];

  final PageController _pageController = PageController();

  void enterRefresh() {
    _refreshController.requestLoading();
  }

  @override
  void initState() {
    _refreshController = RefreshController(initialRefresh: true);
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        if (notification.depth == 0 &&
            notification is ScrollUpdateNotification) {
          final PageMetrics metrics = notification.metrics as PageMetrics;
          final int currentPage = metrics.page?.round() ?? 0;
          if (currentPage != _lastReportedPage) {
            _lastReportedPage = currentPage;
            print("onPageChange + $currentPage");
          }
        }
        return false;
      },
      child: SmartRefresher(
        enablePullUp: true,
        enablePullDown: true,
        footer: const ClassicFooter(
          loadStyle: LoadStyle.ShowWhenLoading,
        ),
        controller: _refreshController,
        header: const MaterialClassicHeader(),
        onRefresh: () async {
          print("onRefresh");
          await Future.delayed(const Duration(milliseconds: 4000));

          if (mounted) setState(() {});
          _refreshController.refreshFailed();
        },
        child: CustomScrollView(
          physics: const PageScrollPhysics(),
          controller: _pageController,
          slivers: <Widget>[
            SliverFillViewport(
                delegate: SliverChildListDelegate(const [
              Center(child: Text("Page One")),
              Center(child: Text("Page Two")),
              Center(child: Text("Page Three")),
              Center(child: Text("Page Four"))
            ]))
          ],
        ),
        onLoading: () {
          print("onLoading");
          Future.delayed(const Duration(milliseconds: 2000)).then((val) {
            _refreshController.loadComplete();
          });
        },
      ),
    );
  }
}
