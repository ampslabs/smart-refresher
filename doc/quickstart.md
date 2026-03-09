---
title: "Quickstart"
description: "Get up and running with smart_refresher in minutes."
---

## Installation

Add `smart_refresher` to your `pubspec.yaml` file:

```yaml
dependencies:
  smart_refresher: ^0.1.1
```

Then run the following command in your terminal:

```bash
flutter pub get
```

## Basic Usage

Wrap your scrollable widget with `SmartRefresher` and provide a `RefreshController`.

```dart
import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

class MyListPage extends StatefulWidget {
  @override
  _MyListPageState createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  List<String> items = ["1", "2", "3", "4", "5"];
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed, use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed, use loadFailed(),if no data return, use loadNoData()
    items.add((items.length + 1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        footer: CustomFooter(
          builder: (context, mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text("pull up load");
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("Load Failed!Click retry!");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("release to load more");
            } else {
              body = Text("No more Data");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
          itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
          itemExtent: 100.0,
          itemCount: items.length,
        ),
      ),
    );
  }
}
```

## Next Steps

Explore the different indicator styles and configurations to match your app's design.

<CardGroup cols={2}>
  <Card title="Global Configuration" icon="gear" href="/configuration">
    Learn how to set defaults for your entire app.
  </Card>
  <Card title="Indicator Gallery" icon="palette" href="/indicators/classic">
    Browse pre-built indicator styles.
  </Card>
</CardGroup>
