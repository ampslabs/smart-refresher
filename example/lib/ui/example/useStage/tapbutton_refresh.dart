/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2020-06-21 1:43 PM
 */

import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

/*
    Achieve requirement:
    Tap a button to trigger refresh instead of a pull-down gesture.
 */
class TapButtonRefreshExample extends StatefulWidget {
  const TapButtonRefreshExample({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TapButtonRefreshExampleState();
  }
}

class _TapButtonRefreshExampleState extends State<TapButtonRefreshExample> {
  List<String> data = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _enablePullDown = false;

  Widget buildEmpty() {
    // There are two ways:
    // This way is more convenient, but it doesn't inherit ListView attributes.
    // If you don't need attributes like physics or cacheExtent, you can return the empty widget directly.
    // Otherwise, return a ListView.
    // Since 1.5.2, you don't need to compute the height via LayoutBuilder. If BoxConstraints are infinite,
    // SmartRefresher automatically converts the height to the viewport's main extent.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          "images/empty1.png",
          fit: BoxFit.cover,
        ),
        const Text("No data, please tap the refresh button")
      ],
    );
    /* Second way:
    return ListView(
      children: [
        Image.asset(
          "images/empty.png",
          fit: BoxFit.cover,
        )
      ],
      physics: const BouncingScrollPhysics(),
      cacheExtent: 100.0,
    );
     */
  }

  @override
  void initState() {
    super.initState();
    _refreshController.headerMode?.addListener(() {
      if (_refreshController.headerMode?.value == RefreshStatus.idle) {
        Future.delayed(const Duration(milliseconds: 20)).then((value) {
          _enablePullDown = false;
          setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        enablePullUp: data.isNotEmpty,
        enablePullDown: _enablePullDown,
        header: const ClassicHeader(),
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 2000));
          if (mounted) {
            setState(() {
              data.add("new data item 1");
              data.add("new data item 2");
              data.add("new data item 3");
              data.add("new data item 4");
              data.add("new data item 5");
              data.add("new data item 6");
            });
          }
          _refreshController.refreshCompleted();
        },
        child: data.isEmpty
            ? buildEmpty()
            : ListView.builder(
                itemBuilder: (c, i) => Card(
                  child: Center(
                    child: Text(data[i]),
                  ),
                ),
                itemCount: data.length,
                itemExtent: 100.0,
              ),
      ),
      appBar: AppBar(
        title: const Text("Tap Button to Refresh"),
        actions: [
          GestureDetector(
            onTap: () {
              _enablePullDown = true;
              setState(() {});
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                _refreshController.requestRefresh();
              });
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.refresh),
            ),
          )
        ],
      ),
    );
  }
}
