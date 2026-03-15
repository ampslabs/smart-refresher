import 'dart:convert';
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  await integrationDriver(
    responseDataCallback: (data) async {
      if (data != null) {
        // ignore: avoid_print
        print('Integration test results:');
        // ignore: avoid_print
        print(jsonEncode(data));
      }
    },
  );
}
