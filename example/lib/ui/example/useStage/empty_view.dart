/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-24 5:13 PM
 */

import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

/*
   When a ListView has no data, we should often return a view that indicates an empty state.
   There are two ways to achieve this, as shown below.
 */
class RefreshWithEmptyView extends StatefulWidget {
  const RefreshWithEmptyView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RefreshWithEmptyViewState();
  }
}

class _RefreshWithEmptyViewState extends State<RefreshWithEmptyView> {
  List<String> data = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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
        const Text("No data, please pull down to refresh")
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
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: data.isNotEmpty,
      enablePullDown: true,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 2000));
        if (mounted) {
          setState(() {
            data.add("new data item");
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
    );
  }
}
