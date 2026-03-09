/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-07-03 5:24 PM
 */

import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

/*
  Notice: If you combine DraggableScrollableSheet with SmartRefresher,
  it does not support enablePullDown; only enablePullUp = true is supported.
  Also, this example uses StatefulBuilder to rebuild the content inside the sheet.
 */
class DraggableLoadingBottomSheet extends StatefulWidget {
  const DraggableLoadingBottomSheet({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DraggableLoadingBottomSheetState();
  }
}

class _DraggableLoadingBottomSheetState
    extends State<DraggableLoadingBottomSheet> {
  final RefreshController _controller = RefreshController();

  List<String> items = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 15; i++) {
      items.add("Item Data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DraggableScrollableSheet'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                isScrollControlled: true,
                builder: (c) {
                  return DraggableScrollableSheet(
                    initialChildSize: 0.8,
                    maxChildSize: 1.0,
                    minChildSize: 0.5,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                        ),
                        child: StatefulBuilder(
                          builder: (BuildContext context2, setter) {
                            return SmartRefresher(
                              controller: _controller,
                              onLoading: () async {
                                await Future.delayed(
                                    const Duration(milliseconds: 1000));
                                for (int i = 0; i < 15; i++) {
                                  items.add("New Item Data");
                                }
                                _controller.loadComplete();
                                setter(() {});
                              },
                              enablePullUp: true,
                              enablePullDown: false,
                              child: ListView.separated(
                                controller: scrollController,
                                separatorBuilder: (c, i) => const Divider(),
                                itemBuilder: (_, e) => SizedBox(
                                  height: 40.0,
                                  child:
                                      Center(child: Text("Menu Item $e")),
                                ),
                                physics: const ClampingScrollPhysics(),
                                itemCount: items.length,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                });
          },
          child: const Text("Click to open Draggable BottomSheet"),
        ),
      ),
    );
  }
}
