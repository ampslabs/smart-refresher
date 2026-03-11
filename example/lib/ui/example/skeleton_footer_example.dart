import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

class SkeletonFooterExamplePage extends StatefulWidget {
  const SkeletonFooterExamplePage({super.key});

  @override
  State<SkeletonFooterExamplePage> createState() =>
      _SkeletonFooterExamplePageState();
}

class _SkeletonFooterExamplePageState extends State<SkeletonFooterExamplePage> {
  final RefreshController _refreshController = RefreshController();
  final List<int> _items = List<int>.generate(16, (int index) => index);
  SkeletonBoneStyle _style = SkeletonBoneStyle.listTile;
  bool _staggered = false;

  Future<void> _onLoading() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    setState(() {
      final int start = _items.length;
      _items.addAll(List<int>.generate(8, (int index) => start + index));
    });
    _refreshController.loadComplete();
  }

  Widget _buildListItem(BuildContext context, int index) {
    final int value = _items[index];
    switch (_style) {
      case SkeletonBoneStyle.listTile:
        return ListTile(
          leading: CircleAvatar(child: Text('${value + 1}')),
          title: Text('List item ${value + 1}'),
          subtitle: const Text('Subtitle copy for pagination preview'),
        );
      case SkeletonBoneStyle.card:
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 140.0,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Card item ${value + 1}'),
                    const SizedBox(height: 8.0),
                    const Text('Media-heavy feed content preview'),
                  ],
                ),
              ),
            ],
          ),
        );
      case SkeletonBoneStyle.textBlock:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Text(
            'Paragraph item ${value + 1}. This preview uses denser body copy so the text-block skeleton layout has a matching target.',
          ),
        );
      case SkeletonBoneStyle.imageRow:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: List<Widget>.generate(3, (int imageIndex) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: imageIndex < 2 ? 8.0 : 0.0),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: ColoredBox(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: Center(
                        child: Text(
                          '${value + 1}-${imageIndex + 1}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
    }
  }

  SkeletonFooter _buildFooter() {
    final int skeletonCount = _style == SkeletonBoneStyle.card ? 2 : 3;
    final double height = switch (_style) {
      SkeletonBoneStyle.card => 540.0,
      SkeletonBoneStyle.imageRow => 192.0,
      SkeletonBoneStyle.textBlock => 240.0,
      SkeletonBoneStyle.listTile => 160.0,
    };
    if (_staggered) {
      return SkeletonFooter.staggered(
        boneStyle: _style,
        skeletonCount: skeletonCount,
        height: height,
      );
    }
    return SkeletonFooter(
      boneStyle: _style,
      skeletonCount: skeletonCount,
      height: height,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skeleton Footer')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 4.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: <Widget>[
                ChoiceChip(
                  label: const Text('List tile'),
                  selected: _style == SkeletonBoneStyle.listTile,
                  onSelected: (_) {
                    setState(() {
                      _style = SkeletonBoneStyle.listTile;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Card'),
                  selected: _style == SkeletonBoneStyle.card,
                  onSelected: (_) {
                    setState(() {
                      _style = SkeletonBoneStyle.card;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Text block'),
                  selected: _style == SkeletonBoneStyle.textBlock,
                  onSelected: (_) {
                    setState(() {
                      _style = SkeletonBoneStyle.textBlock;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Image row'),
                  selected: _style == SkeletonBoneStyle.imageRow,
                  onSelected: (_) {
                    setState(() {
                      _style = SkeletonBoneStyle.imageRow;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Staggered'),
                  selected: _staggered,
                  onSelected: (bool selected) {
                    setState(() {
                      _staggered = selected;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1.0),
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: false,
              enablePullUp: true,
              footer: _buildFooter(),
              onLoading: _onLoading,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: _buildListItem,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
