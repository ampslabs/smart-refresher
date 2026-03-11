import 'package:flutter/material.dart' hide RefreshIndicator;
import 'package:smart_refresher/smart_refresher.dart';

import '../main.dart';
import 'fake_list_item.dart';

class DemoScaffold extends StatefulWidget {
  const DemoScaffold({
    super.key,
    required this.title,
    required this.headerBuilder,
    required this.footerBuilder,
    this.itemCount = 15,
    this.simulatedDelayMs = 900,
    this.showThemeToggle = true,
    this.topContent,
    this.trailing,
  });

  final String title;
  final RefreshIndicator Function() headerBuilder;
  final LoadIndicator Function() footerBuilder;
  final int itemCount;
  final int simulatedDelayMs;
  final bool showThemeToggle;
  final Widget? topContent;
  final Widget? trailing;

  @override
  State<DemoScaffold> createState() => _DemoScaffoldState();
}

class _DemoScaffoldState extends State<DemoScaffold> {
  static const int _pageSize = 10;
  static const int _maxItems = 50;

  late RefreshController _controller;
  late List<int> _items;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _controller = RefreshController();
    _items = List<int>.generate(widget.itemCount, (int index) => index + 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future<void>.delayed(Duration(milliseconds: widget.simulatedDelayMs));
    if (!mounted) {
      return;
    }
    setState(() {
      _page = 1;
      _items = List<int>.generate(widget.itemCount, (int index) => index + 1);
    });
    _controller.refreshCompleted();
    _controller.resetNoData();
  }

  Future<void> _onLoading() async {
    await Future<void>.delayed(Duration(milliseconds: widget.simulatedDelayMs));
    if (!mounted) {
      return;
    }
    if (_items.length >= _maxItems) {
      _controller.loadNoData();
      return;
    }
    setState(() {
      _page++;
      _items.addAll(
        List<int>.generate(
          _pageSize,
          (int index) => (_page - 1) * _pageSize + index + widget.itemCount + 1,
        ),
      );
    });
    _controller.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          if (widget.trailing != null) widget.trailing!,
          if (widget.showThemeToggle) const ThemeModeToggle(),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (widget.topContent != null) widget.topContent!,
          Expanded(
            child: SmartRefresher(
              controller: _controller,
              enablePullUp: true,
              header: widget.headerBuilder(),
              footer: widget.footerBuilder(),
              onRefresh: _onRefresh,
              onLoading: _onLoading,
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
  }
}
