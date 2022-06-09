import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'login_test_spec.screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Should OTP success when Login and OTP success',
    (tester) async {
      // Login Screen
      await LoginTestScreen(tester).run();
    },
  );
}
