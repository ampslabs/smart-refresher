import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_refresher/smart_refresher.dart';

final dataProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  // Simulate network fetch
  await Future.delayed(const Duration(seconds: 2));

  // Randomly throw error or return empty for demo
  // throw Exception('Failed to load data');
  return List.generate(20, (i) => 'Riverpod Item $i');
});

class RiverpodExample extends ConsumerStatefulWidget {
  const RiverpodExample({super.key});

  @override
  ConsumerState<RiverpodExample> createState() => _RiverpodExampleState();
}

class _RiverpodExampleState extends ConsumerState<RiverpodExample> {
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(dataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Integration'),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: () async {
          ref.invalidate(dataProvider);
          await ref.read(dataProvider.future);
          _refreshController.refreshCompleted();
        },
        child: asyncData.when(
          data: (items) => ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(items[index]),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}
