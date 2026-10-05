import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// [text] anywhere in the picker except its title band.
///
/// The band repeats the selected date -- its year included -- so a plain
/// `find.text('2081')` would match the band as well as the year field or a
/// year tile.
Finder outsideBand(String text) => find.byElementPredicate(
      (element) {
        final widget = element.widget;
        if (widget is! Text || widget.data != text) return false;
        var inBand = false;
        element.visitAncestorElements((ancestor) {
          inBand = ancestor.widget.runtimeType.toString() == '_TitleBand';
          return !inBand;
        });
        return !inBand;
      },
      description: 'text "$text" outside the title band',
    );
