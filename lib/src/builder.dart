import 'dart:io';

import 'package:integration_testgen/integration_testgen.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class Builder {
  final _extensions = ['.yaml', '.yml'];
  final _specsSuffix = ['_spec.yaml', '_spec.yml'];
  final _screenSuffix = '_screen.dart';

  Future<bool> build(String currentPath) async {
    final directory = Directory(currentPath);
    for (var file in directory.listSync()) {
      if (await checkFileSupported(file)) {
        /// Create target file
        final filename = p.basename(file.path);
        final targetFilename = filename
            .replaceAll(_specsSuffix.first, _screenSuffix)
            .replaceAll(_specsSuffix.last, _screenSuffix);
        final targetFilePath = '$currentPath/$targetFilename';
        final targetFile = File(targetFilePath);
        print('[INFO] Generating file $targetFilename');

        /// Read file
        final content = await readFile(file.path);

        /// Generate to source dart
        final sourceCode = await generate(content);

        /// Write to file
        final files = await targetFile.writeAsString(sourceCode);
        return await files.exists();
      }
    }
    return false;
  }

  Future<String> generate(String content) async {
    /// Convert content to yaml format
    var ymlSpecs = loadYaml(content);

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
    outputBuffer.writeln(
        "import 'package:widget_tester_extension/widget_tester_extension.dart';");
    outputBuffer.writeln("");

    /// Build class
    final className = "${screenName}TestScreen";
    outputBuffer.writeln("class $className {");
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

    /// Build method run
    outputBuffer.writeln("\tFuture<void> run() async {");
    outputBuffer.write(methodBuffer.toString());
    outputBuffer.writeln("\t}");

    /// Build end class
    outputBuffer.writeln("}");

    return outputBuffer.toString();
  }

  Future<String> readFile(String filepath) async {
    final f = File(filepath);
    return await f.readAsString();
  }

  Future<bool> checkFileSupported(FileSystemEntity file) async {
    final filename = p.basename(file.path);
    final isExtensionSupported =
        _extensions.indexOf(p.extension(file.path)) > -1;
    final isSpecsSuffixSupported =
        _specsSuffix.indexWhere((pattern) => filename.indexOf(pattern) > -1) >
            -1;
    return isExtensionSupported && isSpecsSuffixSupported;
  }
}
