import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

import '../../main.dart';
import '../../widgets/fake_list_item.dart';
import '../../widgets/indicator_chip_selector.dart';

enum _FooterOption {
  classicSpinner,
  classicText,
  skeletonList,
  skeletonCard,
  skeletonText,
}

class FooterComparisonScreen extends StatefulWidget {
  const FooterComparisonScreen({super.key});

  @override
  State<FooterComparisonScreen> createState() => _FooterComparisonScreenState();
}

class _FooterComparisonScreenState extends State<FooterComparisonScreen> {
  late RefreshController _controller;
  _FooterOption _active = _FooterOption.classicSpinner;
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

  LoadIndicator _buildFooter() => switch (_active) {
        _FooterOption.classicSpinner => const ClassicFooter(),
        _FooterOption.classicText => const ClassicFooter(
            idleIcon: SizedBox.shrink(),
            canLoadingIcon: SizedBox.shrink(),
            loadingIcon: SizedBox.shrink(),
          ),
        _FooterOption.skeletonList => const SkeletonFooter(
            boneStyle: SkeletonBoneStyle.listTile,
          ),
        _FooterOption.skeletonCard => const SkeletonFooter(
            boneStyle: SkeletonBoneStyle.card,
          ),
        _FooterOption.skeletonText => const SkeletonFooter(
            boneStyle: SkeletonBoneStyle.textBlock,
          ),
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
        title: const Text('Footer Comparison'),
        actions: const <Widget>[ThemeModeToggle()],
      ),
      body: Column(
        children: <Widget>[
          IndicatorChipSelector<_FooterOption>(
            options: const <(String, _FooterOption)>[
              ('Classic Spinner', _FooterOption.classicSpinner),
              ('Classic Text', _FooterOption.classicText),
              ('Skeleton: List', _FooterOption.skeletonList),
              ('Skeleton: Card', _FooterOption.skeletonCard),
              ('Skeleton: Text', _FooterOption.skeletonText),
            ],
            selected: _active,
            onSelected: (_FooterOption value) {
              _swapController();
              setState(() {
                _active = value;
                _items = List<int>.generate(18, (int index) => index + 1);
              });
            },
          ),
          Expanded(
            child: SmartRefresher(
              key: ValueKey<_FooterOption>(_active),
              controller: _controller,
              enablePullUp: true,
              header: const Material3Header(),
              footer: _buildFooter(),
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
