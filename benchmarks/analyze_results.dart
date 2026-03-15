import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stdout.writeln('Usage: dart analyze_results.dart <path_to_json>');
    return;
  }

  final File file = File(args[0]);
  final String content = file.readAsStringSync();

  // Find the JSON block starting with {"refresh_scroll_timeline":
  final int start = content.indexOf('{"refresh_scroll_timeline":');
  if (start == -1) {
    stdout.writeln('Could not find benchmark data in file.');
    return;
  }

  final String jsonStr = content.substring(start);
  final Map<String, dynamic> data = jsonDecode(jsonStr) as Map<String, dynamic>;
  final Map<String, dynamic> timeline =
      data['refresh_scroll_timeline'] as Map<String, dynamic>;
  final List<dynamic> events = timeline['traceEvents'] as List<dynamic>;

  final List<num> frameTimes = [];
  final Map<String, num> pendingFrames = {};

  for (final dynamic event in events) {
    final Map<String, dynamic> e = event as Map<String, dynamic>;
    if (e['name'] == 'Frame') {
      final String id = e['id'] as String;
      final num ts = e['ts'] as num;
      if (e['ph'] == 'b') {
        pendingFrames[id] = ts;
      } else if (e['ph'] == 'e') {
        if (pendingFrames.containsKey(id)) {
          frameTimes.add(ts - pendingFrames[id]!);
          pendingFrames.remove(id);
        }
      }
    }
  }

  if (frameTimes.isEmpty) {
    stdout.writeln('No frame data found in timeline.');
    return;
  }

  frameTimes.sort();
  final num total = frameTimes.fold(0, (a, b) => a + b);
  final double avg = total / frameTimes.length;
  final num p90 = frameTimes[(frameTimes.length * 0.9).floor()];
  final num maxTime = frameTimes.last;
  final num minTime = frameTimes.first;

  stdout.writeln('--- Performance Stats ---');
  stdout.writeln('Total Frames: ${frameTimes.length}');
  stdout.writeln('Average Frame Time: ${(avg / 1000).toStringAsFixed(2)} ms');
  stdout.writeln('90th Percentile: ${(p90 / 1000).toStringAsFixed(2)} ms');
  stdout.writeln('Max Frame Time: ${(maxTime / 1000).toStringAsFixed(2)} ms');
  stdout.writeln('Min Frame Time: ${(minTime / 1000).toStringAsFixed(2)} ms');

  final double fps = 1000000 / avg;
  stdout.writeln('Estimated FPS: ${fps.toStringAsFixed(1)}');
  stdout.writeln('-------------------------');
}
