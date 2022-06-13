import 'package:integration_testgen/src/builder.dart';
import 'package:path/path.dart' as p;

void main(List<String> arguments) async {
  print('[INFO] Generating build script...');
  final startTime = DateTime.now();
  final builder = Builder();
  final result = await builder.build(p.current);
  final stopTime = DateTime.now();
  final timeUsage =
      stopTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch;
  if (result) {
    print(
      '[INFO] Succeeded after ${timeUsage}ms',
    );
  } else {
    print('[ERROR] Failure after ${timeUsage}ms');
  }
}
