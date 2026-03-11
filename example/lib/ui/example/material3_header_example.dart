import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

/// Demonstrates [Material3Header] with seeded light and dark Material 3 themes.
class Material3HeaderExample extends StatelessWidget {
  /// Creates the Material 3 header example page.
  const Material3HeaderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Material 3 Header')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const <Widget>[
          _ThemePreview(
            title: 'Seeded Light Theme',
            brightness: Brightness.light,
          ),
          SizedBox(height: 16.0),
          _ThemePreview(
            title: 'Seeded Dark Theme',
            brightness: Brightness.dark,
          ),
        ],
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  final String title;
  final Brightness brightness;

  const _ThemePreview({required this.title, required this.brightness});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: brightness,
      ),
      useMaterial3: true,
    );

    return Theme(
      data: theme,
      child: Builder(
        builder: (BuildContext context) {
          return Card(
            clipBehavior: Clip.antiAlias,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: SizedBox(
              height: 320.0,
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(title),
                    subtitle: Text(
                      brightness == Brightness.light
                          ? 'ColorScheme.fromSeed light'
                          : 'ColorScheme.fromSeed dark',
                    ),
                  ),
                  const Divider(height: 1.0),
                  const Expanded(child: _Material3PreviewList()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Material3PreviewList extends StatefulWidget {
  const _Material3PreviewList();

  @override
  State<_Material3PreviewList> createState() => _Material3PreviewListState();
}

class _Material3PreviewListState extends State<_Material3PreviewList> {
  final RefreshController _refreshController = RefreshController();
  late final List<int> _items = List<int>.generate(12, (int index) => index);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      header: const Material3Header(),
      onRefresh: _handleRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1.0),
        itemBuilder: (BuildContext context, int index) {
          final ColorScheme colorScheme = Theme.of(context).colorScheme;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              child: Text('${_items[index] + 1}'),
            ),
            title: Text('Material row ${_items[index] + 1}'),
            subtitle: Text(
              'Pull to refresh using Material3Header',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }
    setState(() {
      _items.insert(0, _items.length);
    });
    _refreshController.refreshCompleted();
  }
}
