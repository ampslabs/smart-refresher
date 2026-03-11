import 'package:flutter/cupertino.dart';
import 'package:smart_refresher/smart_refresher.dart';

/// Demonstrates the `iOS17Header` inside a Cupertino-styled list.
class IOS17HeaderExample extends StatefulWidget {
  /// Creates the iOS 17 header demo page.
  const IOS17HeaderExample({super.key});

  @override
  State<IOS17HeaderExample> createState() => _IOS17HeaderExampleState();
}

class _IOS17HeaderExampleState extends State<IOS17HeaderExample> {
  final RefreshController _refreshController = RefreshController();
  final List<int> _items = List<int>.generate(20, (int index) => index);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }
    setState(() {
      _items.insert(0, _items.length);
    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.light),
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('iOS 17 Header'),
        ),
        child: SafeArea(
          child: SmartRefresher(
            controller: _refreshController,
            header: const iOS17Header(showLastUpdated: true),
            onRefresh: _onRefresh,
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 64.0,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.separator,
                        width: 0.0,
                      ),
                    ),
                  ),
                  child: Text('Message ${_items[index]}'),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
