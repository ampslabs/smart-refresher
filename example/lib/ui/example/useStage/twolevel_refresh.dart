/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-26 4:28 PM
 */

import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:smart_refresher/smart_refresher.dart';

/*
   There are two examples implementing the two-level feature:
   The first one is common: when two-level refreshing, the header follows the list scrolling down. When closing, it still follows the list moving up.
   The second example uses Navigator and maintains the offset when the two-level mode is triggered.
   The header can use ClassicHeader to implement the two-level effect via the outerBuilder (introduced in 1.4.7).
   Important points:
   1. Enable the enableTwoLevel property (default is false).
   2. Use _refreshController.twoLevelComplete() to close the two-level state.
*/
class TwoLevelExample extends StatefulWidget {
  const TwoLevelExample({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TwoLevelExampleState();
  }
}

class _TwoLevelExampleState extends State<TwoLevelExample> {
  final RefreshController _refreshController1 = RefreshController();
  final RefreshController _refreshController2 = RefreshController();
  int _tabIndex = 0;

  @override
  void initState() {
    _refreshController1.headerMode?.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshController1.position?.jumpTo(0);
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration.copyAncestor(
      context: context,
      enableScrollWhenTwoLevel: true,
      maxOverScrollExtent: 120,
      child: Scaffold(
        bottomNavigationBar: !_refreshController1.isTwoLevel
            ? BottomNavigationBar(
                currentIndex: _tabIndex,
                onTap: (index) {
                  _tabIndex = index;
                  if (mounted) setState(() {});
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.add), label: "TwoLevel Example 1"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.border_clear), label: "TwoLevel Example 2")
                ],
              )
            : null,
        body: Stack(
          children: <Widget>[
            Offstage(
              offstage: _tabIndex != 0,
              child: LayoutBuilder(
                builder: (_, c) {
                  return SmartRefresher(
                    header: TwoLevelHeader(
                      textStyle: const TextStyle(color: Colors.white),
                      displayAlignment: TwoLevelDisplayAlignment.fromTop,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("images/secondfloor.jpg"),
                            fit: BoxFit.cover,
                            // Very important attribute, this will affect the animation effect of opening and closing the second floor
                            alignment: Alignment.topCenter),
                      ),
                      twoLevelWidget: const TwoLevelWidget(),
                    ),
                    controller: _refreshController1,
                    enableTwoLevel: true,
                    enablePullDown: true,
                    enablePullUp: true,
                    onLoading: () async {
                      await Future.delayed(const Duration(milliseconds: 2000));
                      _refreshController1.loadComplete();
                    },
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 2000));
                      _refreshController1.refreshCompleted();
                    },
                    onTwoLevel: (bool isOpen) {
                      print("twoLevel opening:$isOpen");
                    },
                    child: CustomScrollView(
                      physics: const ClampingScrollPhysics(),
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 500.0,
                            child: Scaffold(
                              appBar: AppBar(),
                              body: Column(
                                children: <Widget>[
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Click here to go back!"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _refreshController1.requestTwoLevel();
                                    },
                                    child: const Text("Click here to open second floor!"),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Offstage(
              offstage: _tabIndex != 1,
              child: SmartRefresher(
                header: const ClassicHeader(),
                controller: _refreshController2,
                enableTwoLevel: true,
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 2000));
                  _refreshController2.refreshCompleted();
                },
                onTwoLevel: (bool isOpen) {
                  if (isOpen) {
                    _refreshController2.position?.hold(() {});
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (c) => Scaffold(
                                  appBar: AppBar(),
                                  body: const Center(child: Text("Second Floor Refresh")),
                                )))
                        .whenComplete(() {
                      _refreshController2.twoLevelComplete(
                          duration: const Duration(microseconds: 1));
                    });
                  }
                },
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Container(
                        color: Colors.red,
                        height: 680.0,
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Click here to go back!"),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TwoLevelWidget extends StatelessWidget {
  const TwoLevelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("images/secondfloor.jpg"),
            // Very important attribute, this will affect the animation effect of opening and closing the second floor, related to TwoLevelHeader. If the background is consistent, please set it to be the same.
            alignment: Alignment.topCenter,
            fit: BoxFit.cover),
      ),
      child: Stack(
        children: <Widget>[
          Center(
            child: Wrap(
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                  onPressed: () {},
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
          Container(
            height: 60.0,
            alignment: Alignment.bottomLeft,
            child: GestureDetector(
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onTap: () {
                SmartRefresher.of(context)?.controller.twoLevelComplete();
              },
            ),
          ),
        ],
      ),
    );
  }
}
