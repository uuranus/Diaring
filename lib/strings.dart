import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Strings {
  Strings(this.locale);

  final Locale locale;

  static Strings of(BuildContext context) {
    return Localizations.of<Strings>(context, Strings)!;
  }

  Map<String, String> _strings={};

  Future<bool> load() async {
    String data = await rootBundle
        .loadString('locale/${this.locale.languageCode}.json');
    Map<String, dynamic> _result = json.decode(data);

    this._strings = new Map();
    _result.forEach((String key, dynamic value) {
      this._strings[key] = value.toString();
    });

    return true;
  }

  String get(String key) {
    return this._strings[key]!;
  }
}
