import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_spec/integration_spec.dart';
import 'package:integration_spec/widget_tester.dart';

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

	@override
	Future<void> run() async {
		await verifyHelloText();
		await tapNextButton();
		await enterNumberField();
	}
}
