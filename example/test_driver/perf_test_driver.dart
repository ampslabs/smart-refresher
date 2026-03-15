import 'dart:convert';
import 'dart:io';
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  await integrationDriver(
    responseDataCallback: (data) async {
      if (data != null) {
        print('Integration test results:');
        print(jsonEncode(data));
      }
    },
  );
}
