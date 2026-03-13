import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

class BuilderSlotsExample extends StatefulWidget {
  const BuilderSlotsExample({super.key});

  @override
  State<BuilderSlotsExample> createState() => _BuilderSlotsExampleState();
}

class _BuilderSlotsExampleState extends State<BuilderSlotsExample> {
  final RefreshController _refreshController = RefreshController(
    initialContentStatus: ContentStatus.loading,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _refreshController.contentStatus.value = ContentStatus.loading;
    await Future.delayed(const Duration(seconds: 2));
    _refreshController.contentStatus.value = ContentStatus.idle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Builder Slots Demo'),
        actions: [
          PopupMenuButton<ContentStatus>(
            onSelected: (status) {
              _refreshController.contentStatus.value = status;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: ContentStatus.idle, child: Text('Idle (Show List)')),
              const PopupMenuItem(
                  value: ContentStatus.loading, child: Text('Loading Slot')),
              const PopupMenuItem(
                  value: ContentStatus.empty, child: Text('Empty Slot')),
              const PopupMenuItem(
                  value: ContentStatus.error, child: Text('Error Slot')),
            ],
          ),
        ],
      ),
      body: SmartRefresher.builder(
        controller: _refreshController,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          _refreshController.refreshCompleted();
        },
        loading: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initial Loading Slot...'),
            ],
          ),
        ),
        empty: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Empty Slot: No data found'),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
        error: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Error Slot: Something went wrong'),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
        builder: (context, physics) => ListView.builder(
          physics: physics,
          itemCount: 20,
          itemBuilder: (context, index) => ListTile(
            title: Text('Data Item $index'),
          ),
        ),
      ),
    );
  }
}
