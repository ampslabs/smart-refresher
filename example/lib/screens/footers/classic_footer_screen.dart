import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

import '../../widgets/demo_scaffold.dart';

class ClassicFooterScreen extends StatefulWidget {
  const ClassicFooterScreen({super.key});

  @override
  State<ClassicFooterScreen> createState() => _ClassicFooterScreenState();
}

class _ClassicFooterScreenState extends State<ClassicFooterScreen> {
  bool _textOnly = false;

  @override
  Widget build(BuildContext context) {
    final IndicatorThemeData resolution = IndicatorThemeData.resolve(context);
    return DemoScaffold(
      title: 'ClassicFooter',
      headerBuilder: () => const ClassicHeader(),
      footerBuilder: () => ClassicFooter(
        textStyle: resolution.textStyle.copyWith(
          color: resolution.primaryColor,
        ),
        loadingIcon: _textOnly
            ? const SizedBox.shrink()
            : SizedBox(
                width: 18.0,
                height: 18.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: resolution.primaryColor,
                ),
              ),
        idleIcon: _textOnly
            ? const SizedBox.shrink()
            : Icon(
                Icons.expand_less_rounded,
                color: resolution.primaryColor,
              ),
        canLoadingIcon: _textOnly
            ? const SizedBox.shrink()
            : Icon(Icons.sync_rounded, color: resolution.primaryColor),
      ),
      topContent: Card(
        margin: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 4.0),
        child: ExpansionTile(
          title: const Text('Options'),
          childrenPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          children: <Widget>[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Text-only mode'),
              value: _textOnly,
              onChanged: (bool value) => setState(() => _textOnly = value),
            ),
          ],
        ),
      ),
    );
  }
}
