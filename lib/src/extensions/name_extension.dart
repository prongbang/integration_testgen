extension NameExtension on String? {
  String toCamelStartLower() {
    final text = this;
    if (text == null) {
      return '';
    }

    final names = text.split('_');
    var named = '';
    for (var i = 0; i < names.length; i++) {
      if (i == 0) {
        final first = names[i].firstCharacter().toLowerCase();
        final second = names[i].secondsCharacter();
        named = first + second;
      } else {
        named += names[i].toCamelStartUpper();
      }
    }

    return named;
  }

  String toCamelStartUpper() {
    final text = this;
    if (text == null) {
      return '';
    }

    final names = text.split('_');
    var named = '';
    for (var i = 0; i < names.length; i++) {
      final first = names[i].firstCharacter().toUpperCase();
      final second = names[i].secondsCharacter();
      named += first + second;
    }

    return named;
  }

  String firstCharacter() {
    final text = this;
    if (text == null) {
      return '';
    }
    final first = text.substring(0, 1);
    return first;
  }

  String secondsCharacter() {
    final text = this;
    if (text == null) {
      return '';
    }
    final seconds = text.substring(1);
    return seconds;
  }
}
