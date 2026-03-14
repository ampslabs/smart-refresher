import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

import '../../widgets/demo_scaffold.dart';

class Ios17HeaderScreen extends StatefulWidget {
  const Ios17HeaderScreen({super.key});

  @override
  State<Ios17HeaderScreen> createState() => _Ios17HeaderScreenState();
}

class _Ios17HeaderScreenState extends State<Ios17HeaderScreen> {
  double _radius = 10.0;
  bool _showLastUpdated = true;
  bool _enableHaptic = true;
  String? _semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Ios17Header',
      headerBuilder: () => Ios17Header(
        radius: _radius,
        showLastUpdated: _showLastUpdated,
        enableHaptic: _enableHaptic,
        semanticsLabel: _semanticsLabel,
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
              title: const Text('Radius'),
              subtitle: Slider(
                min: 8.0,
                max: 20.0,
                divisions: 6,
                value: _radius,
                label: _radius.toStringAsFixed(0),
                onChanged: (double value) => setState(() => _radius = value),
              ),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Custom Accessibility Label',
                hintText: 'Enter a label for screen readers',
                isDense: true,
              ),
              onChanged: (String value) => setState(() {
                _semanticsLabel = value.isEmpty ? null : value;
              }),
            ),
            const SizedBox(height: 8.0),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show last updated'),
              value: _showLastUpdated,
              onChanged: (bool value) =>
                  setState(() => _showLastUpdated = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable haptic feedback'),
              value: _enableHaptic,
              onChanged: (bool value) => setState(() => _enableHaptic = value),
            ),
          ],
        ),
      ),
    );
  }
}
