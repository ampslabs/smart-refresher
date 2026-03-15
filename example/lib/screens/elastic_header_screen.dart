import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

class ElasticHeaderScreen extends StatefulWidget {
  const ElasticHeaderScreen({super.key});

  @override
  State<ElasticHeaderScreen> createState() => _ElasticHeaderScreenState();
}

class _ElasticHeaderScreenState extends State<ElasticHeaderScreen> {
  final RefreshController _refreshController = RefreshController();

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        header: const ElasticHeader(
          child: Image(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
            ),
            fit: BoxFit.cover,
            height: 200,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text('Elastic Header'),
              pinned: true,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Image(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (c, i) => ListTile(title: Text('Data Item $i')),
                childCount: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
