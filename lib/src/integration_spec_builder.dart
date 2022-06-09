import 'dart:async';

import 'package:build/build.dart';
import 'package:integration_spec/integration_spec.dart';
import 'package:integration_spec/src/domain/spec_matcher.dart';
import 'package:integration_spec/src/extensions/name_extension.dart';
import 'package:yaml/yaml.dart';

class IntegrationSpecBuilder implements Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    /// Each `buildStep` has a single input.
    var inputId = buildStep.inputId;

    print('inputId: $inputId');

    if (inputId.extension != '.yml') {
      print(
          'The extension ${inputId.extension} unsupported, Please change to .yml');
      return;
    }

    /// Create a new target `AssetId` based on the old one.
    var copy = inputId.changeExtension('.screen.dart');
    var contents = await buildStep.readAsString(inputId);

    /// Convert content to yaml format
    var ymlSpecs = loadYaml(contents);

    /// Mapping model
    final screenName = ymlSpecs['screen'];
    final specs = ymlSpecs['specs'] as YamlMap;
    final specsList = <Spec>[];
    for (var spec in specs.entries) {
      specsList.add(Spec(
        name: spec.key,
        config: SpecConfig.fromJson(spec.value),
      ));
    }
    final screen = Screen(name: screenName, specs: specsList);

    /// Generate test screen
    final outputBuffer = StringBuffer();

    /// Build import packages
    outputBuffer.writeln("import 'package:flutter/material.dart';");
    outputBuffer.writeln("import 'package:flutter_test/flutter_test.dart';");
    outputBuffer
        .writeln("import 'package:integration_spec/integration_spec.dart';");
    outputBuffer
        .writeln("import 'package:integration_spec/widget_tester.dart';");
    outputBuffer.writeln("");

    /// Build class
    final className = "${screenName}TestScreen";
    outputBuffer.writeln("class $className extends TestScreen {");
    outputBuffer.writeln("\tfinal WidgetTester tester;\n");

    outputBuffer.writeln("\t$className(this.tester) {");
    outputBuffer
        .writeln("\t\ttester.printToConsole('✓ $screenName Screen Open');");
    outputBuffer.writeln("\t}\n");

    /// Build function
    var methodBuffer = StringBuffer();
    for (var spec in screen.specs) {
      /// Build method name
      final methodName = spec.name.toCamelStartLower();
      outputBuffer.writeln("\tFuture<void> $methodName() async {");
      methodBuffer.writeln('\t\tawait $methodName();');

      /// Build finder
      final finderName = 'finder${spec.name.toCamelStartUpper()}';
      if (spec.config?.key != null) {
        outputBuffer.writeln(
            "\t\tfinal $finderName = find.byKey(const Key('${spec.config?.key}'));");
      } else if (spec.config?.text != null) {
        outputBuffer.writeln(
            "\t\tfinal $finderName = find.text('${spec.config?.text}');");
      }

      /// Build delay
      if (spec.config?.delay != null) {
        outputBuffer.writeln("\t\tawait tester.delay(${spec.config?.delay});");
      }

      /// Build widget tester
      outputBuffer.writeln("\t\tawait tester.pumpAndSettle();");
      outputBuffer.writeln("\t\tawait tester.pumpUntilFound($finderName);");
      switch (spec.config?.type ?? '') {
        case SpecType.verify:

          /// Matcher
          if (spec.config?.matcher == SpecMatcher.nothing) {
            outputBuffer.writeln("\t\texpect($finderName, findsNothing);");
          } else if (spec.config?.matcher == SpecMatcher.one) {
            outputBuffer.writeln("\t\texpect($finderName, findsOneWidget);");
          } else if (spec.config?.matcher != null) {
            outputBuffer.writeln(
                "\t\texpect($finderName, findsNWidgets(${spec.config?.matcher}));");
          }
          break;
        case SpecType.tap:
          outputBuffer.writeln("\t\tawait tester.tap($finderName);");
          break;
        case SpecType.enter:
          outputBuffer.writeln(
              "\t\tawait tester.enterText($finderName, '${spec.config?.text}');");
          break;
      }

      outputBuffer.writeln("\t\tawait tester.pumpAndSettle();");

      /// Build end method
      outputBuffer.writeln("\t}\n");
    }

    /// Build override method run
    outputBuffer.writeln("\t@override");
    outputBuffer.writeln("\tFuture<void> run() async {");
    outputBuffer.write(methodBuffer.toString());
    outputBuffer.writeln("\t}");

    /// Build end class
    outputBuffer.writeln("}");

    /// Write out the new asset.
    await buildStep.writeAsString(copy, outputBuffer.toString());
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        ".yml": [".screen.dart"]
      };
}
