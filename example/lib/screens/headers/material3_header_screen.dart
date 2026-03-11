import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

import '../../widgets/demo_scaffold.dart';

class Material3HeaderScreen extends StatefulWidget {
  const Material3HeaderScreen({super.key});

  @override
  State<Material3HeaderScreen> createState() => _Material3HeaderScreenState();
}

class _Material3HeaderScreenState extends State<Material3HeaderScreen> {
  static const List<Color> _swatches = <Color>[
    Colors.deepPurple,
    Colors.teal,
    Colors.orange,
    Colors.indigo,
    Colors.pink,
  ];

  double _elevation = 6.0;
  Color? _color;
  bool _useStar = false;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Material3Header',
      headerBuilder: () => Material3Header(
        elevation: _elevation,
        color: _color,
        completeIcon: _useStar
            ? Icon(
                Icons.star_rounded,
                color: _color ?? Theme.of(context).colorScheme.primary,
              )
            : null,
      ),
      footerBuilder: () => const ClassicFooter(),
      topContent: Card(
        margin: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 4.0),
        child: ExpansionTile(
          title: const Text('Options'),
          childrenPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Elevation'),
              subtitle: Slider(
                min: 0.0,
                max: 12.0,
                value: _elevation,
                label: _elevation.toStringAsFixed(1),
                onChanged: (double value) => setState(() => _elevation = value),
              ),
            ),
            Wrap(
              spacing: 8.0,
              children: _swatches
                  .map(
                    (Color color) => ChoiceChip(
                      label: const Text(''),
                      avatar: CircleAvatar(backgroundColor: color),
                      selected: _color == color,
                      onSelected: (_) => setState(() => _color = color),
                    ),
                  )
                  .toList(),
            ),
            TextButton(
              onPressed: () => setState(() => _color = null),
              child: const Text('Reset to theme color'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use star complete icon'),
              value: _useStar,
              onChanged: (bool value) => setState(() => _useStar = value),
            ),
          ],
        ),
      ),
    );
  }
}
