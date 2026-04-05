import 'package:flutter/material.dart' hide RefreshIndicator;
import 'package:smart_refresher/smart_refresher.dart';

import '../../main.dart';
import '../../widgets/fake_list_item.dart';

class WaterDropHeaderScreen extends StatefulWidget {
  const WaterDropHeaderScreen({super.key});

  @override
  State<WaterDropHeaderScreen> createState() => _WaterDropHeaderScreenState();
}

class _WaterDropHeaderScreenState extends State<WaterDropHeaderScreen> {
  late RefreshController _controller;
  List<int> _items = List<int>.generate(15, (int index) => index + 1);

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

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _items = List<int>.generate(15, (int index) => index + 1);
    });
    _controller.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WaterDropHeader'),
        actions: const <Widget>[ThemeModeToggle()],
      ),
      body: SmartRefresher(
        controller: _controller,
        header: WaterDropHeader(
          waterDropColor: Theme.of(context).colorScheme.primary,
        ),
        onRefresh: _onRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _items.length,
          itemBuilder: (BuildContext context, int index) {
            return FakeListItem(index: _items[index]);
          },
        ),
      ),
    );
  }
}
