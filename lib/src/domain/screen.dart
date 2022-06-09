import 'package:integration_spec/src/domain/spec.dart';

class Screen {
  String name;
  List<Spec> specs;

  Screen({this.name = '', this.specs = const <Spec>[]});
}
