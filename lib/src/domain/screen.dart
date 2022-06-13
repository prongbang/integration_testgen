import 'package:integration_testgen/src/domain/spec.dart';

class Screen {
  String name;
  List<Spec> specs;

  Screen({this.name = '', this.specs = const <Spec>[]});
}
