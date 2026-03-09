/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-26 11:36 AM
 */

/*
  The basic usage examples
*/

import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';
import '../../Item.dart';

/*
   The most common usage scenarios:
   child can be ListView, GridView, CustomScrollView, or any Widget.
   RefreshConfiguration is a global setting, similar to Theme. All refreshers in the RefreshConfiguration subtree will inherit its properties.
   In this example, RefreshConfiguration is given a headerBuilder property, which becomes the default header indicator for the four refreshers.
   If you use the same indicator across multiple pages, using RefreshConfiguration can significantly simplify your code.
*/

class BasicExample extends StatefulWidget {
  const BasicExample({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BasicExampleState();
  }
}

class _BasicExampleState extends State<BasicExample>
    with SingleTickerProviderStateMixin {
  List<String> data1 = [], data2 = [], data3 = [];
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 6, vsync: this);
    for (int i = 0; i < 10; i++) {
      data1.add("Item $i");
    }
    for (int i = 0; i < 10; i++) {
      data2.add("Item $i");
    }
    for (int i = 0; i < 10; i++) {
      data3.add("Item $i");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration.copyAncestor(
      enableLoadingWhenFailed: true,
      context: context,
      headerBuilder: () => WaterDropMaterialHeader(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      footerTriggerDistance: 30.0,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            isScrollable: true,
            controller: _tabController,
            tabs: const <Widget>[
              Tab(
                text: "ListView",
              ),
              Tab(
                text: "GridView",
              ),
              Tab(
                text: "Non-Scrollable",
              ),
              Tab(
                text: "SliverAppBar+List",
              ),
              Tab(
                text: "GridView+ListView",
              ),
              Tab(
                text: "Horizontal+ListView",
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: const <Widget>[
            Scrollbar(
              child: OnlyListView(),
            ),
            Scrollbar(
              child: OnlyGridView(),
            ),
            Scrollbar(
              child: NoScrollable(),
            ),
            Scrollbar(
              child: SliverAppBarWithList(),
            ),
            Scrollbar(
              child: GridAndList(),
            ),
            Scrollbar(
              child: SwiperAndList(),
            )
          ],
        ),
      ),
    );
  }
}

// Only ListView
class OnlyListView extends StatefulWidget {
  const OnlyListView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _OnlyListViewState();
  }
}

class _OnlyListViewState extends State<OnlyListView> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<String> data = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];
  final GlobalKey _contentKey = GlobalKey();
  final GlobalKey _refresherKey = GlobalKey();

  Widget buildCtn() {
    return ListView.separated(
      key: _contentKey,
      reverse: true,
      padding: const EdgeInsets.only(left: 5, right: 5),
      itemBuilder: (c, i) => Item(
        title: data[i],
      ),
      separatorBuilder: (context, index) {
        return Container(
          height: 0.5,
          color: Colors.greenAccent,
        );
      },
      itemCount: data.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      key: _refresherKey,
      controller: _refreshController,
      enablePullUp: true,
      physics: const BouncingScrollPhysics(),
      footer: const ClassicFooter(
        loadStyle: LoadStyle.ShowWhenLoading,
        completeDuration: Duration(milliseconds: 500),
      ),
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 1000));

        for (int i = 0; i < 10; i++) {
          data.add("Item $i");
        }

        if (mounted) setState(() {});
        _refreshController.refreshCompleted();
      },
      onLoading: () async {
        await Future.delayed(const Duration(milliseconds: 180));
        if (mounted) setState(() {});
        _refreshController.loadFailed();
      },
      child: buildCtn(),
    );
  }
}

// Only GridView
class OnlyGridView extends StatefulWidget {
  const OnlyGridView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _OnlyGridViewState();
  }
}

class _OnlyGridViewState extends State<OnlyGridView> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<String> data = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];

  Widget buildCtn() {
    return GridView.builder(
      physics: const ClampingScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (c, i) => Item(
        title: data[i],
      ),
      itemCount: data.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      header: const ClassicHeader(),
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 1000));

        if (data.isEmpty) {
          for (int i = 0; i < 10; i++) {
            data.add("Item $i");
          }
        }
        if (mounted) setState(() {});
        _refreshController.refreshCompleted();
      },
      onLoading: () async {
        await Future.delayed(const Duration(milliseconds: 1000));
        for (int i = 0; i < 10; i++) {
          data.add("Item $i");
        }
        if (mounted) setState(() {});
        _refreshController.loadComplete();
      },
      child: buildCtn(),
    );
  }
}

// No vertical Scrollable (like SingleChildScrollView)
class NoScrollable extends StatefulWidget {
  const NoScrollable({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NoScrollableState();
  }
}

class _NoScrollableState extends State<NoScrollable> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<String> data = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];

  Widget buildCtn() {
    return SizedBox(
        height: 1000.0,
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.redAccent,
              height: 200.0,
            ),
            const Text("Title"),
            Container(
              color: Colors.redAccent,
              height: 200.0,
            ),
            const Text("Title"),
            Container(
              color: Colors.redAccent,
              height: 200.0,
            ),
            const Text("Title"),
            Container(
              color: Colors.redAccent,
              height: 200.0,
            ),
            const Text("Title"),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      header: const WaterDropHeader(),
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 1000));

        if (data.isEmpty) {
          for (int i = 0; i < 10; i++) {
            data.add("Item $i");
          }
        }
        if (mounted) setState(() {});
        _refreshController.refreshCompleted();
      },
      onLoading: () async {
        await Future.delayed(const Duration(milliseconds: 1000));
        for (int i = 0; i < 10; i++) {
          data.add("Item $i");
        }
        if (mounted) setState(() {});
        _refreshController.loadComplete();
      },
      child: buildCtn(),
    );
  }
}

// SliverAppBar + ListView
class SliverAppBarWithList extends StatefulWidget {
  const SliverAppBarWithList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SliverAppBarWithListState();
  }
}

class _SliverAppBarWithListState extends State<SliverAppBarWithList> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<String> data = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];

  Widget buildCtn() {
    return CustomScrollView(
      slivers: <Widget>[
        const SliverToBoxAdapter(),
        const SliverAppBar(
          title: Text("SliverAppBar"),
          expandedHeight: 100.0,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (c, i) => Item(title: data[i]),
            childCount: data.length,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      header: const WaterDropHeader(),
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 1000));

        if (data.isEmpty) {
          for (int i = 0; i < 10; i++) {
            data.add("Item $i");
          }
        }
        if (mounted) setState(() {});
        _refreshController.refreshCompleted();
      },
      onLoading: () async {
        await Future.delayed(const Duration(milliseconds: 1000));
        for (int i = 0; i < 10; i++) {
          data.add("Item $i");
        }
        if (mounted) setState(() {});
        _refreshController.loadComplete();
      },
      child: buildCtn(),
    );
  }
}

// GridView + ListView
class GridAndList extends StatefulWidget {
  const GridAndList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GridAndListState();
  }
}

class _GridAndListState extends State<GridAndList> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<String> data = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];

  Widget buildCtn() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverGrid(
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          delegate: SliverChildBuilderDelegate(
            (c, i) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Icon(Icons.storage), Text("Menu Title")],
            ),
            childCount: 6,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (c, i) => Item(title: data[i]),
            childCount: data.length,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      header: const WaterDropHeader(),
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 1000));

        if (data.isEmpty) {
          for (int i = 0; i < 10; i++) {
            data.add("Item $i");
          }
        }
        if (mounted) setState(() {});
        _refreshController.refreshCompleted();
      },
      onLoading: () async {
        await Future.delayed(const Duration(milliseconds: 1000));
        for (int i = 0; i < 10; i++) {
          data.add("Item $i");
        }
        if (mounted) setState(() {});
        _refreshController.loadComplete();
      },
      child: buildCtn(),
    );
  }
}

// Horizontal Swiper + List
class SwiperAndList extends StatefulWidget {
  const SwiperAndList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SwiperAndListState();
  }
}

class _SwiperAndListState extends State<SwiperAndList> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<String> data = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];

  Widget buildCtn() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: PageView.builder(
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 200,
                  child: Image.asset(
                    "images/empty.png",
                    fit: BoxFit.cover,
                  ),
                );
              },
              itemCount: 10,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (c, i) => Item(title: data[i]),
            childCount: data.length,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      header: const WaterDropHeader(),
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 1000));

        if (data.isEmpty) {
          for (int i = 0; i < 10; i++) {
            data.add("Item $i");
          }
        }
        if (mounted) setState(() {});
        _refreshController.refreshCompleted();
      },
      onLoading: () async {
        await Future.delayed(const Duration(milliseconds: 1000));
        for (int i = 0; i < 10; i++) {
          data.add("Item $i");
        }
        if (mounted) setState(() {});
        _refreshController.loadComplete();
      },
      child: buildCtn(),
    );
  }
}
