# integration_testgen

Generate Page Object Model dart class by spec.yml

## Getting started

- Now install the application via homebrew

```shell
$ brew tap prongbang/homebrew-formulae
$ brew install integration_testgen
```

Or Install Manual

- Clone project 

```yaml
git clone https://github.com/prongbang/integration_testgen.git
cd integration_testgen
```

- Build to binary file

```yaml
dart compile exe bin/integration_testgen.dart -o bin/integration_testgen
```

## Usage

- pubspec.yml

```yaml
dev_dependencies:
  widget_tester_extension: ^0.0.1
```

- Create spec `login_test_spec.yml` in `integration_test/login` folder

```shell
project
  - integration_test
    - login/login_test_spec.yml
```

and enter script

```yaml
screen: "Login"
specs:
  verify_hello_text:
    text: "Hello"
    type: "verify"
    matcher: "one" # "nothing", "one", "2"
  tap_next_button:
    key: "nextButton"
    type: "tap"
    delay: 500
  enter_number_field:
    key: "numberField"
    type: "enter"
    text: "123456"
```

## Run to generate in root project

```shell
time bin/integration_testgen
```

## Output

- login_test_screen.dart

```shell
project
  - integration_test
    - login/login_test_spec.yml
    - login/login_test_screen.dart
```

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_testgen/integration_testgen.dart';
import 'package:integration_testgen/widget_tester.dart';

class LoginTestScreen extends TestScreen {
	final WidgetTester tester;

	LoginTestScreen(this.tester) {
		tester.printToConsole('✓ Login Screen Open');
	}

	Future<void> verifyHelloText() async {
		final finderVerifyHelloText = find.text('Hello');
		await tester.pumpAndSettle();
		await tester.pumpUntilFound(finderVerifyHelloText);
		expect(finderVerifyHelloText, findsOneWidget);
		await tester.pumpAndSettle();
	}

	Future<void> tapNextButton() async {
		final finderTapNextButton = find.byKey(const Key('nextButton'));
		await tester.delay(500);
		await tester.pumpAndSettle();
		await tester.pumpUntilFound(finderTapNextButton);
		await tester.tap(finderTapNextButton);
		await tester.pumpAndSettle();
	}

	Future<void> enterNumberField() async {
		final finderEnterNumberField = find.byKey(const Key('numberField'));
		await tester.pumpAndSettle();
		await tester.pumpUntilFound(finderEnterNumberField);
		await tester.enterText(finderEnterNumberField, '123456');
		await tester.pumpAndSettle();
	}

	Future<void> run() async {
		await verifyHelloText();
		await tapNextButton();
		await enterNumberField();
	}
}
```

- login_test.dart

```shell
project
  - integration_test
    - login/login_test_spec.yml
    - login/login_test_screen.dart
    - login/login_test.dart
```

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'login_test_screen.dart';

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
```
