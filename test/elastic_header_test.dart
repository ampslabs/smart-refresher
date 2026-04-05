import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

void main() {
  testWidgets('ElasticHeader stretches during pull-down', (tester) async {
    final RefreshController refreshController = RefreshController();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SmartRefresher(
          controller: refreshController,
          header: const ElasticHeader(
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: Center(child: Text('Elastic Content')),
            ),
          ),
          child: ListView.builder(
            itemCount: 20,
            itemBuilder: (c, i) => ListTile(title: Text('Item $i')),
          ),
        ),
      ),
    ));

    // Pull down to trigger construction and stretching
    final gesture = await tester.startGesture(const Offset(200, 100));
    await gesture.moveBy(const Offset(0, 150)); // Pull by 150px
    await tester.pump();

    // Verify Content exists
    expect(find.text('Elastic Content'), findsOneWidget);

    // Verify Transform exists
    final Transform transform = tester.widget(find
        .descendant(
          of: find.byType(ElasticHeader),
          matching: find.byType(Transform),
        )
        .first);
    final Matrix4 matrix = transform.transform;

    // The scale factor should be greater than 1.0 (scaling on Y axis)
    // newFactor = 1.0 + (150 / 100) = 2.5
    expect(matrix.storage[5], 2.5);

    await gesture.up();
    await tester.pumpAndSettle();
  });
}
