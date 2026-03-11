import 'package:flutter/material.dart' hide RefreshIndicator;
import 'package:smart_refresher/smart_refresher.dart';

import '../../main.dart';
import '../../widgets/fake_list_item.dart';
import '../../widgets/indicator_chip_selector.dart';

enum _HeaderOption { classic, material3, ios17 }

class HeaderComparisonScreen extends StatefulWidget {
  const HeaderComparisonScreen({super.key});

  @override
  State<HeaderComparisonScreen> createState() => _HeaderComparisonScreenState();
}

class _HeaderComparisonScreenState extends State<HeaderComparisonScreen> {
  late RefreshController _controller;
  _HeaderOption _active = _HeaderOption.classic;
  List<int> _items = List<int>.generate(18, (int index) => index + 1);

  @override
  void initState() {
    super.initState();
    _controller = RefreshController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _swapController() {
    final RefreshController previous = _controller;
    _controller = RefreshController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      previous.dispose();
    });
  }

  RefreshIndicator _buildHeader() => switch (_active) {
        _HeaderOption.classic => const ClassicHeader(),
        _HeaderOption.material3 => const Material3Header(),
        _HeaderOption.ios17 => const iOS17Header(showLastUpdated: true),
      };

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }
    setState(() {
      _items = List<int>.generate(18, (int index) => index + 1);
    });
    _controller.refreshCompleted();
    _controller.resetNoData();
  }

  Future<void> _onLoading() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }
    if (_items.length >= 42) {
      _controller.loadNoData();
      return;
    }
    setState(() {
      _items.addAll(
        List<int>.generate(8, (int index) => _items.length + index + 1),
      );
    });
    _controller.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Header Comparison'),
        actions: const <Widget>[ThemeModeToggle()],
      ),
      body: Column(
        children: <Widget>[
          IndicatorChipSelector<_HeaderOption>(
            options: const <(String, _HeaderOption)>[
              ('Classic', _HeaderOption.classic),
              ('Material 3', _HeaderOption.material3),
              ('iOS 17', _HeaderOption.ios17),
            ],
            selected: _active,
            onSelected: (_HeaderOption value) {
              _swapController();
              setState(() {
                _active = value;
                _items = List<int>.generate(18, (int index) => index + 1);
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pull down to compare the active header on the same content list.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: SmartRefresher(
              key: ValueKey<_HeaderOption>(_active),
              controller: _controller,
              enablePullUp: true,
              header: _buildHeader(),
              footer: const ClassicFooter(),
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                itemCount: _items.length,
                itemBuilder: (BuildContext context, int index) {
                  return FakeListItem(index: _items[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
