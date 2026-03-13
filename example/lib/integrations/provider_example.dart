import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_refresher/smart_refresher.dart';

class DataProvider extends ChangeNotifier {
  List<String> items = [];
  bool isLoading = false;

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    items = List.generate(20, (i) => 'Provider Item $i');
    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await Future.delayed(const Duration(seconds: 2));
    items = List.generate(20, (i) => 'Refreshed Provider Item $i');
    notifyListeners();
  }
}

class ProviderExample extends StatefulWidget {
  const ProviderExample({super.key});

  @override
  State<ProviderExample> createState() => _ProviderExampleState();
}

class _ProviderExampleState extends State<ProviderExample> {
  final RefreshController _refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DataProvider()..fetchData(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Provider Integration')),
        body: Consumer<DataProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return SmartRefresher(
              controller: _refreshController,
              onRefresh: () async {
                await provider.refreshData();
                _refreshController.refreshCompleted();
              },
              child: ListView.builder(
                itemCount: provider.items.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(provider.items[index]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
