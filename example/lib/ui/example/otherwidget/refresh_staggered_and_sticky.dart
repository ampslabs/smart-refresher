/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-07-23 9:09 PM
 */
import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

/*
   Use refresh with StaggeredGridView or StickyHeader.
   These two plugins are from letsar (https://github.com/letsar).
 */
class RefreshStaggeredAndSticky extends StatefulWidget {
  const RefreshStaggeredAndSticky({super.key});

  @override
  RefreshStaggeredAndStickyState createState() =>
      RefreshStaggeredAndStickyState();
}

class RefreshStaggeredAndStickyState extends State<RefreshStaggeredAndSticky>
    with TickerProviderStateMixin {
  late RefreshController _refreshController;

  List<Widget> data = [];

  int length = 10;

  void _getDatas() {
    data.add(Row(
      children: <Widget>[
        TextButton(
            onPressed: () {
              _refreshController.requestRefresh();
            },
            child: const Text("Request Refresh")),
        TextButton(
            onPressed: () {
              _refreshController.requestLoading();
            },
            child: const Text("Request Loading"))
      ],
    ));
    for (int i = 0; i < 13; i++) {
      data.add(GestureDetector(
        child: Container(
          color: const Color.fromARGB(255, 250, 250, 250),
          child: Card(
            margin:
                const EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
            child: Center(
              child: Text('Data $i'),
            ),
          ),
        ),
        onTap: () {
          _refreshController.requestRefresh();
        },
      ));
    }
  }

  void enterRefresh() {
    _refreshController.requestLoading();
  }

  @override
  void initState() {
    _refreshController = RefreshController(initialRefresh: true);
    _getDatas();
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  List<bool> expand = [false, false, false, false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    List<Widget> slivers = [];
    for (int i = 0; i < expand.length; i++) {
      slivers.add(SliverStickyHeader(
        header: GestureDetector(
          child: Container(
            height: 60.0,
            color: Colors.lightBlue,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.centerLeft,
            child: Text(
              'Header #$i',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          onTap: () {
            expand[i] = !expand[i];
            setState(() {});
          },
        ),
        sliver: expand[i]
            ? SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => ListTile(
                    leading: const CircleAvatar(
                      child: Text('0'),
                    ),
                    title: Text('List tile #$i'),
                  ),
                  childCount: 4,
                ),
              )
            : null,
      ));
    }
    slivers.add(SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      childCount: length,
      itemBuilder: (BuildContext context, int index) => Container(
          color: Colors.green,
          height: index.isEven ? 100 : 60,
          child: Center(
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text('$index'),
            ),
          )),
    ));
    return LayoutBuilder(
      builder: (i, c) {
        return SmartRefresher(
          enablePullUp: true,
          enablePullDown: true,
          controller: _refreshController,
          header: const MaterialClassicHeader(),
          onRefresh: () async {
            print("onRefresh");
            await Future.delayed(const Duration(milliseconds: 4000));
            if (mounted) setState(() {});
            _refreshController.refreshFailed();
          },
          child: CustomScrollView(
            slivers: slivers,
          ),
          onLoading: () {
            print("onLoading");
            Future.delayed(const Duration(milliseconds: 2000)).then((val) {
              length += 10;
              if (mounted) setState(() {});
              _refreshController.loadComplete();
            });
          },
        );
      },
    );
  }
}
