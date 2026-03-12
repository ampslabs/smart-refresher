import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

class GlassHeaderExample extends StatefulWidget {
  const GlassHeaderExample({super.key});

  @override
  State<GlassHeaderExample> createState() => _GlassHeaderExampleState();
}

class _GlassHeaderExampleState extends State<GlassHeaderExample>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GlassHeader'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Tab>[Tab(text: 'Gradient'), Tab(text: 'Photo')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          _GradientBackgroundDemo(),
          _PhotoBackgroundDemo(),
        ],
      ),
    );
  }
}

class _GradientBackgroundDemo extends StatefulWidget {
  const _GradientBackgroundDemo();

  @override
  State<_GradientBackgroundDemo> createState() => _GradientBackgroundDemoState();
}

class _GradientBackgroundDemoState extends State<_GradientBackgroundDemo> {
  final RefreshController _controller = RefreshController();
  final List<String> _items = List<String>.generate(20, (int i) => 'Item ${i + 1}');

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    _controller.refreshCompleted();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
        ),
      ),
      child: SmartRefresher(
        controller: _controller,
        onRefresh: _onRefresh,
        header: const GlassHeader(),
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(_items[index], style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                'Pull down to see glass effect',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PhotoBackgroundDemo extends StatefulWidget {
  const _PhotoBackgroundDemo();

  @override
  State<_PhotoBackgroundDemo> createState() => _PhotoBackgroundDemoState();
}

class _PhotoBackgroundDemoState extends State<_PhotoBackgroundDemo> {
  final RefreshController _controller = RefreshController();

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    _controller.refreshCompleted();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1507525428034-b723cf961d3e'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black.withValues(alpha: 0.25),
        child: SmartRefresher(
          controller: _controller,
          onRefresh: _onRefresh,
          header: const GlassHeader(color: Colors.white),
          child: ListView.builder(
            itemCount: 25,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                color: Colors.black.withValues(alpha: 0.25),
                margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: ListTile(
                  title: Text(
                    'Scenic item ${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Backdrop blur reads from photo details',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
