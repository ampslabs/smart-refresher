/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/5 6:10 PM
 */

import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:smart_refresher/smart_refresher.dart';
import '../../Item.dart';

class IndicatorActivity extends StatefulWidget {
  final String title;
  final Widget? header;
  final Widget? footer;
  final bool enableOverScroll;
  final bool reverse;

  const IndicatorActivity(
      {super.key, required this.title,
      this.header,
      this.reverse = false,
      this.footer,
      this.enableOverScroll = true});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _IndicatorActivityState();
  }
}

class _IndicatorActivityState extends State<IndicatorActivity> {
  List<Widget> items = [];
  late RefreshController _refreshController;

  void _init() {
    for (int i = 0; i < 15; i++) {
      items.add(Item(
        title: "Data$i",
      ));
    }
  }

  late ScrollController _scrollController;

  @override
  void initState() {
    // TODO: implement initState
    _scrollController = ScrollController();
    _refreshController = RefreshController();
    Future.delayed(Duration(milliseconds: 3000)).then((_) {
//      _jumpTo(0.0);
    });
    _init();

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Builder(
        builder: (c) {
          return SmartRefresher(
              onRefresh: _onRefresh,
              onLoading: () {
                _onLoading(c);
              },
              header: widget.header,
              footer: widget.footer,
              enablePullDown: true,
              enablePullUp: true,
              controller: _refreshController,
              child: ListView.builder(
                itemBuilder: (c, i) => items[i],
                itemExtent: 100.0,
                controller: _scrollController,
                reverse: widget.reverse,
                itemCount: items.length,
              ));
        },
      ),
    );
  }

  void _onRefresh() {
    print("onRefresh");
    Future.delayed(Duration(milliseconds: 1000)).then((_) {
      items.add(Item(title: "Data"));
      if (mounted) setState(() {});
      _refreshController.refreshCompleted();
    });
  }

  void _onLoading(BuildContext context) {
    print("onLoading");
    Future.delayed(Duration(milliseconds: 1000)).then((_) {
      _refreshController.loadComplete();
    });
  }
}
