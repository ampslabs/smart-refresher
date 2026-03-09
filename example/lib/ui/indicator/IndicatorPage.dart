/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/5 6:07 PM
 */

import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';
import 'base/IndicatorActivity.dart';

class IndicatorPage extends StatefulWidget {
  const IndicatorPage({super.key, this.title = ""});

  final String title;

  @override
  _IndicatorPageState createState() => _IndicatorPageState();
}

class _IndicatorPageState extends State<IndicatorPage> {
  late List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.5),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) => items[index],
    );
  }

  @override
  void didChangeDependencies() {
    items = [
      IndicatorItem(
          title: "Classic (Follow)",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const IndicatorActivity(
                      title: "Classic (Follow)",
                      header: ClassicHeader(refreshStyle: RefreshStyle.Follow),
                    )));
          },
          imgRes: "images/classical_follow.gif"),
      IndicatorItem(
          title: "Classic (Unfollow)",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const IndicatorActivity(
                      title: "Classic (Unfollow)",
                      header:
                          ClassicHeader(refreshStyle: RefreshStyle.UnFollow),
                    )));
          },
          imgRes: "images/classical_unfollow.gif"),
      IndicatorItem(
          title: "WaterDrop Header",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const IndicatorActivity(
                    reverse: false,
                    title: "WaterDrop Header",
                    header: WaterDropHeader())));
          },
          imgRes: "images/warterdrop.gif"),
      IndicatorItem(
          title: "Material Classic",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const IndicatorActivity(
                    title: "Material Classic",
                    header: MaterialClassicHeader(
                      distance: 40,
                    ))));
          },
          imgRes: "images/material_classic.gif"),
      IndicatorItem(
          title: "Bezier + Circle",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const IndicatorActivity(
                    reverse: false,
                    title: "Bezier + Circle",
                    header: BezierCircleHeader(
                      dismissType: BezierDismissType.scaleToCenter,
                    ))));
          },
          imgRes: "images/bezier.gif"),
      IndicatorItem(
          title: "Material WaterDrop",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const IndicatorActivity(
                    reverse: false,
                    title: "Material WaterDrop",
                    header: WaterDropMaterialHeader(color: Colors.red))));
          },
          imgRes: "images/material_waterdrop.gif"),
      IndicatorItem(
          title: "Footer (Always Show)",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const IndicatorActivity(
                      title: "Footer (Always Show)",
                      footer: ClassicFooter(
                        height: 80.0,
                        loadStyle: LoadStyle.ShowAlways,
                      ),
                    )));
          },
          imgRes: "images/loadstyle1.gif"),
      IndicatorItem(
          title: "Footer (Always Hide)",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    RefreshConfiguration.copyAncestor(
                      context: context,
                      footerTriggerDistance: -30.0,
                      enableLoadingWhenFailed: true,
                      maxUnderScrollExtent: 100.0,
                      child: const IndicatorActivity(
                          reverse: false,
                          title: "Footer (Always Hide)",
                          footer: ClassicFooter(
                            loadStyle: LoadStyle.HideAlways,
                          )),
                    )));
          },
          imgRes: "images/loadstyle2.gif"),
      IndicatorItem(
          title: "Footer (Show When Loading)",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    RefreshConfiguration.copyAncestor(
                      context: context,
                      enableLoadingWhenFailed: true,
                      footerTriggerDistance: -60.0,
                      child: RefreshConfiguration.copyAncestor(
                        context: context,
                        enableLoadingWhenFailed: true,
                        maxUnderScrollExtent: 100.0,
                        footerTriggerDistance: -45.0,
                        child: const IndicatorActivity(
                            reverse: false,
                            title: "Footer (Show When Loading)",
                            footer: ClassicFooter(
                              loadStyle: LoadStyle.ShowWhenLoading,
                            )),
                      ),
                    )));
          },
          imgRes: "images/loadstyle3.gif"),
    ];
    super.didChangeDependencies();
  }
}

class IndicatorItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _IndicatorItemState();
  }

  final VoidCallback onClick;
  final String imgRes;
  final String title;

  const IndicatorItem(
      {super.key, required this.title, required this.imgRes, required this.onClick});
}

class _IndicatorItemState extends State<IndicatorItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onClick,
      child: Card(
        child: Column(
          children: <Widget>[
            Center(
              child: Image.asset(
                widget.imgRes,
                fit: BoxFit.cover,
                width: 180.0,
              ),
            ),
            Center(
              child: Text(widget.title),
            )
          ],
        ),
      ),
    );
  }
}
