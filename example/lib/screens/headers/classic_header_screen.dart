import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

import '../../widgets/demo_scaffold.dart';

class ClassicHeaderScreen extends StatefulWidget {
  const ClassicHeaderScreen({super.key});

  @override
  State<ClassicHeaderScreen> createState() => _ClassicHeaderScreenState();
}

class _ClassicHeaderScreenState extends State<ClassicHeaderScreen> {
  RefreshStyle _style = RefreshStyle.follow;
  bool _showIcons = true;
  String _idle = 'Pull to refresh';
  String _canRefresh = 'Release to refresh';
  String _refreshing = 'Refreshing…';
  String _completed = 'Done';

  @override
  Widget build(BuildContext context) {
    final IndicatorThemeData resolution = IndicatorThemeData.resolve(context);

    return DemoScaffold(
      title: 'ClassicHeader',
      headerBuilder: () => ClassicHeader(
        refreshStyle: _style,
        idleText: _idle,
        releaseText: _canRefresh,
        refreshingText: _refreshing,
        completeText: _completed,
        textStyle: resolution.textStyle.copyWith(
          color: resolution.primaryColor,
        ),
        idleIcon: _showIcons
            ? Icon(
                Icons.arrow_downward_rounded,
                color: resolution.primaryColor,
              )
            : null,
        releaseIcon: _showIcons
            ? Icon(Icons.refresh_rounded, color: resolution.primaryColor)
            : null,
        completeIcon: _showIcons
            ? Icon(Icons.check_rounded, color: resolution.primaryColor)
            : null,
        refreshingIcon: _showIcons
            ? SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: resolution.primaryColor,
                ),
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
            DropdownButtonFormField<RefreshStyle>(
              initialValue: _style,
              decoration: const InputDecoration(labelText: 'RefreshStyle'),
              items: RefreshStyle.values
                  .map(
                    (RefreshStyle style) => DropdownMenuItem<RefreshStyle>(
                      value: style,
                      child: Text(style.name),
                    ),
                  )
                  .toList(),
              onChanged: (RefreshStyle? value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _style = value;
                });
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show icons'),
              value: _showIcons,
              onChanged: (bool value) => setState(() => _showIcons = value),
            ),
            TextFormField(
              initialValue: _idle,
              decoration: const InputDecoration(labelText: 'Idle label'),
              onChanged: (String value) => setState(() => _idle = value),
            ),
            TextFormField(
              initialValue: _canRefresh,
              decoration: const InputDecoration(labelText: 'Can refresh label'),
              onChanged: (String value) => setState(() => _canRefresh = value),
            ),
            TextFormField(
              initialValue: _refreshing,
              decoration: const InputDecoration(labelText: 'Refreshing label'),
              onChanged: (String value) => setState(() => _refreshing = value),
            ),
            TextFormField(
              initialValue: _completed,
              decoration: const InputDecoration(labelText: 'Completed label'),
              onChanged: (String value) => setState(() => _completed = value),
            ),
          ],
        ),
      ),
    );
  }
}
