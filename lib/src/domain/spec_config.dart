import 'package:yaml/yaml.dart';

class SpecConfig {
  String? key;
  String? text;
  String type;
  String? action;
  int? delay;
  String? matcher;

  SpecConfig({
    this.key,
    this.text,
    this.type = '',
    this.action = '',
    this.delay,
    this.matcher,
  });

  factory SpecConfig.fromJson(YamlMap json) {
    return SpecConfig(
      key: json['key'],
      text: json['text'],
      type: json['type'],
      action: json['action'],
      delay: json['delay'],
      matcher: json['matcher'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['text'] = text;
    data['type'] = type;
    data['action'] = action;
    data['delay'] = delay;
    data['matcher'] = matcher;
    return data;
  }
}
