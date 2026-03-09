import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

class Test4 extends StatefulWidget {
  const Test4({super.key});

  @override
  Test4State createState() => Test4State();
}

class Test4State extends State<Test4> with TickerProviderStateMixin {
  ValueNotifier<double> topOffsetLis = ValueNotifier(0.0);
  ValueNotifier<double> bottomOffsetLis = ValueNotifier(0.0);
  late RefreshController _refreshController;

  List<Widget> data = [];

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
            child: const Text("Request Loading")),
      ],
    ));
    for (int i = 0; i < 22; i++) {
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
    _getDatas();
    _refreshController = RefreshController(initialRefresh: false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration.copyAncestor(
      context: context,
      hideFooterWhenNotFull: false,
      child: SmartRefresher.builder(
        enablePullUp: true,
        enablePullDown: true,
        builder: (context, physics) {
          return CustomScrollView(physics: physics, slivers: [
            const MaterialClassicHeader(),
            const SliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 3000,
                    color: Colors.red,
                  ),
                  Center(
                    child: Row(
                      children: <Widget>[
                        ElevatedButton(
                          child: const Text("Request Refresh (Move)"),
                          onPressed: () {
                            _refreshController.requestRefresh();
                          },
                        ),
                        ElevatedButton(
                          child: const Text("Request Loading"),
                          onPressed: () {
                            _refreshController.requestLoading();
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 3000,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
            const ClassicFooter(),
          ]);
        },
        onRefresh: () async {
          print("onRefresh");
          await Future.delayed(const Duration(milliseconds: 1300));
          _refreshController.refreshCompleted();
        },
        onLoading: () async {
          await Future.delayed(const Duration(milliseconds: 1300));
          _refreshController.loadComplete();
        },
        controller: _refreshController,
      ),
    );
  }

  bool get wantKeepAlive => false;
}

class CirclePainter extends CustomClipper<Path> {
  final double offset;
  final bool up;

  CirclePainter({required this.offset, required this.up});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (!up) path.moveTo(0.0, size.height);
    path.cubicTo(
        0.0,
        up ? 0.0 : size.height,
        size.width / 2,
        up ? offset * 2.3 : size.height - offset * 2.3,
        size.width,
        up ? 0.0 : size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return oldClipper != this;
  }
}

class RefreshListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RefreshListViewState();
  }

  final ScrollPhysics physics;
  final List<Widget> slivers;

  const RefreshListView(
      {super.key, required this.slivers, required this.physics});
}

class _RefreshListViewState extends State<RefreshListView> {
  bool show = true;

  @override
  Widget build(BuildContext context) {
    return show
        ? CustomScrollView(
            slivers: widget.slivers,
            physics: const AlwaysScrollableScrollPhysics(),
          )
        : const CupertinoActivityIndicator();
  }
}
