import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

import '../../widgets/demo_scaffold.dart';
import '../../widgets/indicator_chip_selector.dart';

class SkeletonFooterScreen extends StatefulWidget {
  const SkeletonFooterScreen({super.key});

  @override
  State<SkeletonFooterScreen> createState() => _SkeletonFooterScreenState();
}

class _SkeletonFooterScreenState extends State<SkeletonFooterScreen> {
  BoneStyle _style = BoneStyle.list;
  int _count = 3;
  bool _staggered = true;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'SkeletonFooter',
      headerBuilder: () => const Material3Header(),
      footerBuilder: () => SkeletonFooter(
        boneStyle: _style,
        skeletonCount: _count,
        staggered: _staggered,
      ),
      topContent: Card(
        margin: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 4.0),
        child: ExpansionTile(
          title: const Text('Options'),
          childrenPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          children: <Widget>[
            IndicatorChipSelector<BoneStyle>(
              options: const <(String, BoneStyle)>[
                ('List', BoneStyle.list),
                ('Card', BoneStyle.card),
                ('Text', BoneStyle.text),
                ('Compact', BoneStyle.compact),
              ],
              selected: _style,
              onSelected: (BoneStyle value) => setState(() => _style = value),
            ),
            Row(
              children: <Widget>[
                const Text('Skeleton count'),
                const Spacer(),
                IconButton(
                  onPressed: _count > 1 ? () => setState(() => _count--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_count'),
                IconButton(
                  onPressed: _count < 5 ? () => setState(() => _count++) : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Staggered widths'),
              value: _staggered,
              onChanged: (bool value) => setState(() => _staggered = value),
            ),
          ],
        ),
      ),
    );
  }
}
