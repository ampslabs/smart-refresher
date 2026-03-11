/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-24 17:21
 */
import 'package:example/ui/example/customindicator/footer_underscroll.dart';
import 'package:example/ui/example/customindicator/shimmer_indicator.dart';
import 'package:example/ui/example/skeleton_footer_example.dart';
import 'package:example/ui/example/useStage/force_full_one_page.dart';
import 'package:flutter/material.dart';
import 'otherwidget/refresh_staggered_and_sticky.dart';
import 'package:example/ui/example/useStage/empty_view.dart';
import 'customindicator/gif_indicator_example1.dart';
import 'package:example/ui/example/useStage/hidefooter_bycontent.dart';
import 'package:example/ui/example/otherwidget/refesh_expansiopn_panel_list_example.dart';
import 'package:example/ui/example/useStage/horizontal+reverse.dart';
import 'package:example/ui/example/useStage/Nested.dart';
import 'package:example/ui/example/otherwidget/refresh_animatedlist_example.dart';
import 'package:example/ui/example/customindicator/spinkit_header.dart';
import 'package:example/ui/example/useStage/basic.dart';
import 'package:example/ui/example/otherwidget/refresh_pageView_example.dart';
import 'package:example/ui/example/customindicator/link_header_example.dart';
import 'package:example/ui/example/useStage/twolevel_refresh.dart';
import 'useStage/qq_chat_list.dart';
import 'otherwidget/refresh_recordable_listview_example.dart';
import 'otherwidget/draggable_bottomsheet_loadmore.dart';
import 'useStage/tapbutton_refresh.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ExamplePageState();
  }
}

class ExampleItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExampleItemState();
  }

  final VoidCallback onClick;
  final String title;

  const ExampleItem({super.key, required this.title, required this.onClick});
}

class _ExampleItemState extends State<ExampleItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onClick(),
      child: SizedBox(
        height: 100.0,
        child: Card(child: Center(child: Text(widget.title))),
      ),
    );
  }
}

class _ExamplePageState extends State<ExamplePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<ExampleItem> items1 = [
      ExampleItem(
        title: "Basic Usage",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const BasicExample();
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "Hide Footer Manually",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  body: const HideFooterManual(),
                  appBar: AppBar(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "Horizontal Refresh",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  body: const HorizontalRefresh(),
                  appBar: AppBar(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "Tap Button to Refresh",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const TapButtonRefreshExample();
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "Refresh in NestedScrollView",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const NestedRefresh();
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "Mock QQ Chat",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const QQChatList();
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "Empty View + Refresh",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  body: const RefreshWithEmptyView(),
                  appBar: AppBar(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "Taobao Second Floor Example",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const TwoLevelExample();
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "Force Full Page",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  body: const ForceFullExample(),
                  appBar: AppBar(),
                );
              },
            ),
          );
        },
      ),
    ];
    final List<ExampleItem> items2 = [
      ExampleItem(
        title: "AnimatedList + Refresher",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  body: const AnimatedListExample(),
                  appBar: AppBar(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "ExpansionPanelList Usage",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  appBar: AppBar(),
                  body: const RefreshExpansionPanelList(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "Load More + DraggableSheet",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  appBar: AppBar(),
                  body: const DraggableLoadingBottomSheet(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "StickyHeader + StaggeredGridView",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  appBar: AppBar(),
                  body: const RefreshStaggeredAndSticky(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "PageView + SmartRefresher",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  body: const PageViewExample(),
                  appBar: AppBar(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "ReorderableListView",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  body: const ReorderableListDemo(),
                  appBar: AppBar(),
                );
              },
            ),
          );
        },
      ),
    ];

    final List<ExampleItem> items3 = [
      ExampleItem(
        title: "Simple Custom Header",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  body: const CustomHeaderExample(),
                  appBar: AppBar(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "LinkHeader Example",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const LinkHeaderExample();
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "Shimmer Indicator Example",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  appBar: AppBar(),
                  body: const ShimmerIndicatorExample(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "Gif Indicator Example 1",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(),
                  body: const GifIndicatorExample1(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "Convert Footer to Header Style",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const ConvertFooter();
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "Skeleton Footer Example",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const SkeletonFooterExamplePage();
              },
            ),
          );
        },
      ),
    ];

    return Column(
      children: <Widget>[
        Container(
          height: 50.0,
          color: Colors.greenAccent,
          child: TabBar(
            controller: _tabController,
            tabs: const <Widget>[
              Tab(text: "Usage Scenarios"),
              Tab(text: "Special Components"),
              Tab(text: "Custom Indicators"),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              ListView(children: items1),
              ListView(children: items2),
              ListView(children: items3),
            ],
          ),
        ),
      ],
    );
  }
}
