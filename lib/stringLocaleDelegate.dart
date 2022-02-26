import 'dart:async';

import 'package:flutter/material.dart';
import 'package:diaring/strings.dart';

class StringLocaleDelegate extends LocalizationsDelegate<Strings> {
  const StringLocaleDelegate();

  @override
  bool isSupported(Locale locale) => ['ko', 'en'].contains(locale.languageCode);

  @override
  Future<Strings> load(Locale locale) async {
    Strings _strings = new Strings(locale);
    await _strings.load();
    return _strings;
  }

  @override
  bool shouldReload(StringLocaleDelegate old) => false;
}